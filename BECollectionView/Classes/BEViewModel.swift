//
//  BEViewModel.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

open class BEViewModel<T: Hashable> {
    // MARK: - Properties
    let initialData: T
    private var requestDisposable: Disposable?
    public private(set) var data: T
    
    // MARK: - Subject
    let state: BehaviorRelay<BEFetcherState<T>>
    
    // MARK: - Initializer
    public init(initialData: T) {
        self.initialData = initialData
        data = initialData
        state = BehaviorRelay<BEFetcherState<T>>(value: .initializing)
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
    
    // MARK: - Asynchronous request handler
    open func createRequest() -> Single<T> {
        // delay for simulating loading, MUST OVERRIDE
        Single<T>.just(data).delay(.seconds(2), scheduler: MainScheduler.instance)
    }
    
    open func shouldRequest() -> Bool {
        state.value != .loading
    }
    
    open func request(reload: Bool = false) {
        if reload {
            // cancel previous request
            requestDisposable?.dispose()
        } else if !shouldRequest() {
            // there is an running operation
            return
        }
        requestDisposable = createRequest()
            .subscribe(onSuccess: {newData in
                self.handleNewData(newData)
            }, onFailure: {error in
                self.handleError(error)
            })
    }
    
    open func handleNewData(_ newData: T) {
        data = newData
        state.accept(.loaded(data))
    }
    
    open func handleError(_ error: Error) {
        state.accept(.error(error))
    }
    
    // MARK: - Observable
    open var dataDidChange: Observable<Void> {
        state.distinctUntilChanged().map {_ in ()}
    }
    
    open var dataObservable: Observable<T?> {
        state
            .map { state -> T? in
                switch state {
                case .loaded:
                    return self.data
                default:
                    return nil
                }
            }
    }
}
