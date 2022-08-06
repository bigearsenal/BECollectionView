//
//  BEViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import Combine
import BECollectionView_Core

@MainActor
open class BEStreamViewModel<Item: Hashable>: ObservableObject {
    // MARK: - Properties

    let initialData: Item

    /// Current request
    var task: AnyCancellable?

    /// Current data
    @Published public private(set) var data: Item

    /// Last occurred error
    public private(set) var error: Error?

    // MARK: - Subject
    
    @Published public var state = BEFetcherState.initializing

    // MARK: - Initializer

    public init(initialData: Item) {
        self.initialData = initialData
        data = initialData
    }

    deinit { task?.cancel() }

    // MARK: - Actions

    open func clear() {
        data = initialData
        state = .initializing
    }

    open func reload() {
        clear()
        fetch(force: true)
    }

    public func cancelRequest() {
        task?.cancel()
    }

    // MARK: - Asynchronous request handler
    open func isFetchable() -> Bool {
        state != .loading
    }

    /// Fetch next item
    open func next() -> AnyPublisher<Item, Error> {
        // delay for simulating loading, MUST OVERRIDE
        Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    open func fetch(force: Bool = false) {
        if force {
            // cancel previous request
            cancelRequest()
        } else if !isFetchable() {
            // there is an running operation
            return
        }
        
        state = .loading
        
        task = next()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.state = .loaded
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] newData in
                self?.handleData(newData)
            })
    }

    /// processes incoming data
    open func handleData(_ newData: Item) {
        data = newData
        error = nil
    }

    /// handles occurred error
    open func handleError(_ error: Error) {
        self.error = error
        state = .error
    }

    // MARK: - Observable

    open var dataDidChange: AnyPublisher<Void, Never> {
        $state.removeDuplicates {
            switch ($0, $1) {
            case (.initializing, .initializing):
                return true
            default:
                return false
            }
        }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
