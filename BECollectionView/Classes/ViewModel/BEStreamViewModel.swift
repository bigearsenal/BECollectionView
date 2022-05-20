//
//  BEViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxCocoa
import RxSwift

open class BEStreamViewModel<Item: Hashable> {
    // MARK: - Properties

    let initialData: Item

    /// Current request
    var requestDisposable: Disposable?

    /// Current data
    public private(set) var data: Item

    /// Last occurred error
    public private(set) var error: Error?

    /// Current view model state
    public var currentState: BEFetcherState { state.value }

    // MARK: - Subject

    public let state: BehaviorRelay<BEFetcherState>

    // MARK: - Initializer

    public init(initialData: Item) {
        self.initialData = initialData
        data = initialData
        state = BehaviorRelay<BEFetcherState>(value: .initializing)
    }

    deinit { requestDisposable?.dispose() }

    // MARK: - Actions

    open func clear() {
        data = initialData
        state.accept(.initializing)
    }

    open func reload() {
        clear()
        fetch(force: true)
    }

    public func cancelRequest() {
        requestDisposable?.dispose()
    }

    // MARK: - Asynchronous request handler
    open func isFetchable() -> Bool {
        state.value != .loading
    }

    /// Fetch next item
    open func next() -> Observable<Item> {
        // delay for simulating loading, MUST OVERRIDE
        Observable<Item>.just(data)
    }

    open func fetch(force: Bool = false) {
        if force {
            // cancel previous request
            cancelRequest()
        } else if !isFetchable() {
            // there is an running operation
            return
        }
        
        state.accept(.loading)
        requestDisposable = next()
            .subscribe(onNext: { [weak self] newData in
                self?.handleData(newData)
            }, onError: { [weak self] error in
                self?.handleError(error)
            }, onCompleted: { [weak self] in
                self?.state.accept(.loaded)
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
        state.accept(.error)
    }

    // MARK: - Observable

    open var dataDidChange: Observable<Void> {
        state.distinctUntilChanged {
            switch ($0, $1) {
            case (.initializing, .initializing):
                return true
            default:
                return false
            }
        }.map { _ in () }
    }

    open var dataObservable: Observable<Item?> {
        state
            .map { [weak self] state -> Item? in
                switch state {
                case .loaded:
                    return self?.data
                default:
                    return nil
                }
            }
    }

    open var stateObservable: Observable<BEFetcherState> { state.asObservable() }
}
