import Foundation
import Combine
import BECollectionView_Core

open class BECollectionViewModel<T: Hashable>: BEViewModel<[T]>, BECollectionViewModelType {
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
        self.state = state
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
        
        task?.cancel()
        
        task = Task {
            let onSuccess = onSuccessFilterNewData ?? {[weak self] newData in
                newData.filter {!(self?.data.contains($0) == true)}
            }
            var data = self.data
            let newData = try await self.createRequest()
            data = onSuccess(newData) + data
            self.overrideData(by: data)
        }
        
        offset = originalOffset
    }
    
    public func getCurrentPage() -> Int? {
        guard isPaginationEnabled, limit != 0 else {return nil}
        return offset / limit
    }
    
    // MARK: - Helper
    public func batchUpdate(closure: ([T]) -> [T]) {
        let newData = closure(data)
        overrideData(by: newData)
    }
    
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
    
    open var dataDidChange: AnyPublisher<Void, Never> {
        $data.map {_ in ()}.eraseToAnyPublisher()
    }
}

@MainActor
open class BEViewModel<T: Hashable>: ObservableObject {
    // MARK: - Properties
    public let initialData: T
    
    public var task: Task<Void, Error>?
    
    @Published public var data: T
    @Published public var state: BEFetcherState = .initializing
    @Published public var error: Error?
    
    // MARK: - Subject
    
    // MARK: - Initializer
    public init(initialData: T) {
        self.initialData = initialData
        data = initialData
        bind()
    }
    
    open func bind() {}
    
    // MARK: - Actions
    open func flush() {
        data = initialData
        state = .initializing
        error = nil
    }
    
    open func reload() {
        flush()
        request(reload: true)
    }
    
    // MARK: - Asynchronous request handler
    open func createRequest() async throws -> T {
        fatalError("Must override")
    }
    
    open func shouldRequest() -> Bool {
        state == .loading
    }
    
    open func request(reload: Bool = false) {
        if reload {
            // cancel previous request
            task?.cancel()
        } else if !shouldRequest() {
            // there is an running operation
            return
        }
        
        state = .loading
        error = nil
        
        task = Task {
            do {
                let newData = try await createRequest()
                handleNewData(newData)
            } catch {
                if error is CancellationError {
                    return
                }
                handleError(error)
            }
        }
    }
    
    open func handleNewData(_ newData: T) {
        data = newData
        error = nil
        state = .loaded
    }
    
    open func handleError(_ error: Error) {
        self.error = error
        state = .error
    }
}
