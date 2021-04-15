//
//  BEListViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift

public protocol BEListViewModelType {
    var dataDidChange: Observable<Void> {get}
    var currentState: BEFetcherState {get}
    var isPaginationEnabled: Bool {get}
    
    func reload()
    func convertDataToAnyHashable() -> [AnyHashable]
    func fetchNext()
    func setState(_ state: BEFetcherState, withData data: [AnyHashable]?)
    func refreshUI()
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
        var newData = self.join(newItems)
        
        // resign state
        if !isPaginationEnabled || newItems.count < limit {
            isLastPageLoaded = true
        }
        
        // handle new data
        if let customFilter = customFilter {
            newData = newData.filter {customFilter($0)}
        }
        super.handleNewData(newData)
        
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
        if newData != data {
            super.handleNewData(newData)
        }
    }
    
    public func setState(_ state: BEFetcherState, withData data: [AnyHashable]? = nil) {
        self.state.accept(state)
        if let data = data as? [T] {
            overrideData(by: data)
        }
    }
    
    public func refreshUI() {
        state.accept(state.value)
    }
    
    // MARK: - Helper
    @discardableResult
    open func updateItem(where predicate: (T) -> Bool, transform: (T) -> T?) -> Bool {
        switch state.value {
        case .loaded :
            // modify items
            var itemsChanged = false
            if let index = data.firstIndex(where: predicate),
               let item = transform(data[index]),
               item != data[index]
            {
                itemsChanged = true
                var data = self.data
                data[index] = item
                handleNewData(data)
            }
            
            return itemsChanged
        default:
            return false
        }
    }
    
    @discardableResult
    open func insert(_ item: T, where predicate: (T) -> Bool, shouldUpdate: Bool = false) -> Bool
    {
        switch state.value {
        case .loaded :
            // check if item exists in data
            guard let index = data.firstIndex(where: predicate) else {
                var data = self.data
                data.append(item)
                handleNewData(data)
                return true
            }
            
            // update item
            if shouldUpdate && data[index] != item {
                var data = self.data
                data[index] = item
                handleNewData(data)
                return true
            }
        default:
            break
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
            handleNewData(data)
        }
        return nil
    }
    
    public func convertDataToAnyHashable() -> [AnyHashable] {
        data as [AnyHashable]
    }
}
