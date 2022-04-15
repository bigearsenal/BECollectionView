//
//  BEListViewModel.swift
//  BECollectionView
//
//  Created by Long Tran on 13/04/2022.
//

import Foundation
import RxSwift

open class BEStreamListViewModel<T: Hashable>: BEStreamViewModel<[T]>, BEListViewModelType {
    // MARK: - Properties

    public var isPaginationEnabled: Bool
    public var customFilter: ((T) -> Bool)?
    public var customSorter: ((T, T) -> Bool)?
    public var isEmpty: Bool { isLastPageLoaded && data.isEmpty }

    // For pagination
    public var limit: Int
    public var offset: Int
    private var cache: [T] = []
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

    override open func clear() {
        offset = 0
        isLastPageLoaded = false
        super.clear()
    }

    // MARK: - Asynchronous request handler

    override open func isFetchable() -> Bool { super.isFetchable() && !isLastPageLoaded }

    public func fetchNext() { super.fetch() }

    override open func fetch(force: Bool) {
        if force {
            // cancel previous request
            cancelRequest()
        } else if !isFetchable() {
            // there is an running operation
            return
        }

        state.accept(.loading)
        cache = []
        requestDisposable = next()
            .subscribe(onNext: { [weak self] newData in
                self?.handleData(newData)
            }, onError: { [weak self] error in
                self?.handleError(error)
            }, onCompleted: { [weak self] in
                guard let self = self else { return }
                if !self.isPaginationEnabled || self.cache.count < self.limit {
                   self.isLastPageLoaded = true
                }
                self.offset += self.limit
                self.state.accept(.loaded)
            })
    }

    override open func handleData(_ newItems: [T]) {
        cache.append(contentsOf: newItems)
        var newData = join(newItems)
        
        let mappedData = map(newData: newData)
        super.handleData(mappedData)
        
        state.accept(.loading)
    }

    open func join(_ newItems: [T]) -> [T] {
        if !isPaginationEnabled { return newItems }
        return data + newItems.filter { !data.contains($0) }
    }

    public func overrideData(by newData: [T]) {
        let newData = map(newData: newData)
        if newData != data { super.handleData(newData) }
    }

    open func map(newData: [T]) -> [T] {
        var newData = newData
        if let customFilter = customFilter { newData = newData.filter { customFilter($0) } }
        if let sorter = customSorter { newData = newData.sorted(by: sorter) }
        return newData
    }

    public func setState(_ state: BEFetcherState, withData data: [AnyHashable]? = nil) {
        self.state.accept(state)
        if let data = data as? [T] { overrideData(by: data) }
    }

    public func refreshUI() {
        overrideData(by: data)
    }

    public func getCurrentPage() -> Int? {
        guard isPaginationEnabled, limit != 0 else { return nil }
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
    open func insert(_ item: T, where predicate: ((T) -> Bool)? = nil, shouldUpdate: Bool = false) -> Bool {
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
