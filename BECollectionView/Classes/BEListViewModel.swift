//
//  BEListViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

open class BEListViewModel<T: Hashable>: BEViewModel<[T]> {
    // MARK: - Properties
    public var isPaginationEnabled: Bool
    
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
        super.init(initialData: [])
    }
    
    // MARK: - Actions
    public override func flush() {
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
        
        // handle new data
        super.handleNewData(newData)
        
        // get next offset
        offset += limit
    }
    
    func join(_ newItems: [T]) -> [T] {
        if !isPaginationEnabled {
            return newItems
        }
        return data + newItems.filter {!data.contains($0)}
    }
    
    // MARK: - Helper
    @discardableResult
    func updateItem(where predicate: (T) -> Bool, transform: (T) -> T?) -> Bool {
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
    func insert(_ item: T, where predicate: (T) -> Bool, shouldUpdate: Bool = false) -> Bool
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
    func removeItem(where predicate: (T) -> Bool) -> T? {
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
}
