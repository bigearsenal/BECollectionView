//
//  BEListViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift
import BECollectionView_Core

public protocol BEListViewModelType {
    var dataDidChange: Observable<Void> {get}
    var currentState: BEFetcherState {get}
    var isPaginationEnabled: Bool {get}
    
    func reload()
    func convertDataToAnyHashable() -> [AnyHashable]
    func fetchNext()
    func setState(_ state: BEFetcherState, withData data: [AnyHashable]?)
    func refreshUI()
    
    func getCurrentPage() -> Int?
}

public extension BEListViewModelType {
    func getData<T: Hashable>(type: T.Type) -> [T] {
        convertDataToAnyHashable().compactMap {$0 as? T}
    }
}

open class BEListViewModel<T: Hashable>: BEViewModel<[T]>, BEListViewModelType {
    // MARK: - Properties
    public var isPaginationEnabled: Bool
    public var customFilter: ((T) -> Bool)?
    public var customSorter: ((T, T) -> Bool)?
    public var isEmpty: Bool {isLastPageLoaded && data.count == 0}
    
    // For pagination
    public var limit: Int
    public var offset: Int
    private var isLastPageLoaded = false
    
    // MARK: - Initializer
    public init(
        initialData: [T] = [],
        isPaginationEnabled: Bool = false,
        limit: Int = 10,
        offset: Int = 0
    ) {
        self.isPaginationEnabled = isPaginationEnabled
        self.limit = limit
        self.offset = offset
        super.init(initialData: initialData)
    }
    
    // MARK: - Actions
    open override func flush() {
        offset = 0
        isLastPageLoaded = false
        super.flush()
    }
    
    // MARK: - Asynchronous request handler
    open override func shouldRequest() -> Bool {
        super.shouldRequest() && !isLastPageLoaded
    }
    
    open func fetchNext() {
        super.request()
    }
    
    open override func handleNewData(_ newItems: [T]) {
        let newData = self.join(newItems)
        
        // resign state
        if !isPaginationEnabled || newItems.count < limit {
            isLastPageLoaded = true
        }
        
        // map
        let mappedData = map(newData: newData)
        super.handleNewData(mappedData)
        
        // get next offset
        offset += limit
    }
    
    open func join(_ newItems: [T]) -> [T] {
        if !isPaginationEnabled {
            return newItems
        }
        return data + newItems.filter {!data.contains($0)}
    }
    
    public func overrideData(by newData: [T]) {
        let newData = map(newData: newData)
        if newData != data {
            super.handleNewData(newData)
        }
    }
    
    open func map(newData: [T]) -> [T] {
        var newData = newData
        if let customFilter = customFilter {
            newData = newData.filter {customFilter($0)}
        }
        if let sorter = self.customSorter {
            newData = newData.sorted(by: sorter)
        }
        return newData
    }
    
    public func setState(_ state: BEFetcherState, withData data: [AnyHashable]? = nil) {
        self.state.accept(state)
        if let data = data as? [T] {
            overrideData(by: data)
        }
    }
    
    public func refreshUI() {
        overrideData(by: data)
    }
    
    open func updateFirstPage(onSuccessFilterNewData: (([T]) -> [T])? = nil) {
        let originalOffset = offset
        offset = 0
        
        requestDisposable?.dispose()
        
        requestDisposable = createRequest()
            .subscribe(onSuccess: { [weak self] newData in
                guard let self = self else {return}
                let onSuccess = onSuccessFilterNewData ?? {[weak self] newData in
                    newData.filter {!(self?.data.contains($0) == true)}
                }
                var data = self.data
                data = onSuccess(newData) + data
                self.overrideData(by: data)
            }, onFailure: { error in
                // TODO: - Handle error when updating first page
            })
        offset = originalOffset
    }
    
    public func getCurrentPage() -> Int? {
        guard isPaginationEnabled, limit != 0 else {return nil}
        return offset / limit
    }
    
    // MARK: - Helper
    @discardableResult
    open func updateItem(where predicate: (T) -> Bool, transform: (T) -> T?) -> Bool {
        // modify items
        var itemsChanged = false
        if let index = data.firstIndex(where: predicate),
           let item = transform(data[index]),
           item != data[index]
        {
            itemsChanged = true
            var data = self.data
            data[index] = item
            overrideData(by: data)
        }
        
        return itemsChanged
    }
    
    @discardableResult
    open func insert(_ item: T, where predicate: ((T) -> Bool)? = nil, shouldUpdate: Bool = false) -> Bool
    {
        var items = data
        
        // update mode
        if let predicate = predicate {
            if let index = items.firstIndex(where: predicate), shouldUpdate {
                items[index] = item
                overrideData(by: items)
                return true
            }
        }
        
        // insert mode
        else {
            items.append(item)
            overrideData(by: items)
            return true
        }
        
        return false
    }
    
    @discardableResult
    open func removeItem(where predicate: (T) -> Bool) -> T? {
        var result: T?
        var data = self.data
        if let index = data.firstIndex(where: predicate) {
            result = data.remove(at: index)
        }
        if result != nil {
            overrideData(by: data)
        }
        return nil
    }
    
    public func convertDataToAnyHashable() -> [AnyHashable] {
        data as [AnyHashable]
    }
}
