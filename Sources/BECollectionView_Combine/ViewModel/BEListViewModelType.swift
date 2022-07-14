import Foundation
import Combine
import BECollectionView_Core

public protocol BEListViewModelType {
    var dataDidChange: AnyPublisher<Void, Never> {get}
    var currentState: BEFetcherState {get}
    var isPaginationEnabled: Bool {get}
    
    func reload()
    func convertDataToAnyHashable() -> [AnyHashable]
    func fetchNext()
//    func setState(_ state: BEFetcherState, withData data: [AnyHashable]?)
//    func refreshUI()
    
//    func getCurrentPage() -> Int?
}

public extension BEListViewModelType {
    func getData<T: Hashable>(type: T.Type) -> [T] {
        convertDataToAnyHashable().compactMap {$0 as? T}
    }
}


