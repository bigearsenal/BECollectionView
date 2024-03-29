//
//  BEViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift
import RxCocoa
import BECollectionView_Core

open class BEViewModel<T: Hashable> {
    // MARK: - Properties
    let initialData: T
    var requestDisposable: Disposable?
    public private(set) var data: T
    public private(set) var error: Error?
    public var currentState: BEFetcherState {
        state.value
    }
    
    // MARK: - Subject
    let state: BehaviorRelay<BEFetcherState>
    
    // MARK: - Initializer
    public init(initialData: T) {
        self.initialData = initialData
        data = initialData
        state = BehaviorRelay<BEFetcherState>(value: .initializing)
        bind()
    }
    
    deinit {
        requestDisposable?.dispose()
    }
    
    open func bind() {}
    
    // MARK: - Actions
    open func flush() {
        data = initialData
        state.accept(.initializing)
    }
    
    open func reload() {
        flush()
        request(reload: true)
    }
    
    public func cancelRequest() {
        requestDisposable?.dispose()
    }
    
    // MARK: - Asynchronous request handler
    open func createRequest() -> Single<T> {
        // delay for simulating loading, MUST OVERRIDE
        Single<T>.just(data)
    }
    
    open func shouldRequest() -> Bool {
        state.value != .loading
    }
    
    open func request(reload: Bool = false) {
        if reload {
            // cancel previous request
            cancelRequest()
        } else if !shouldRequest() {
            // there is an running operation
            return
        }
        state.accept(.loading)
        requestDisposable = createRequest()
            .subscribe(onSuccess: {[weak self] newData in
                self?.handleNewData(newData)
            }, onFailure: {[weak self] error in
                self?.handleError(error)
            })
    }
    
    open func handleNewData(_ newData: T) {
        data = newData
        error = nil
        state.accept(.loaded)
    }
    
    open func handleError(_ error: Error) {
        self.error = error
        state.accept(.error)
    }
    
    // MARK: - Observable
    open var dataDidChange: Observable<Void> {
        state.distinctUntilChanged({
            switch ($0, $1) {
            case (.initializing, .initializing),  (.loading, .loading):
                return true
            default:
                return false
            }
        }).map {_ in ()}
    }
    
    open var dataObservable: Observable<T?> {
        state
            .map { [weak self] state -> T? in
                switch state {
                case .loaded:
                    return self?.data
                default:
                    return nil
                }
            }
    }
    
    open var stateObservable: Observable<BEFetcherState> {
        state.asObservable()
    }
}
