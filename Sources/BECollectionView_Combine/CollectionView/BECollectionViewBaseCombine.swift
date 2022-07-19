import Foundation
import Combine
import CombineCocoa
import BECollectionView_Core

public typealias BECollectionViewDelegate = BECollectionView_Core.BECollectionViewDelegate
public typealias BECollectionViewBase = BECollectionView_Core.BECollectionViewBase

open class BECollectionViewBaseCombine: BECollectionViewBase {
    private var subscriptions = [AnyCancellable]()
    
    open override func commonInit() {
        super.commonInit()
        bind()
    }
    
    // MARK: - Binding
    open func bind() {
        var publisher = dataDidChangePublisher()
        
        if SystemVersion.isIOS13() {
            publisher = publisher
                .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.reloadData { [weak self] in
                    self?.dataDidLoad()
                }
            }
            .store(in: &subscriptions)
        
        // did end decelerating (ex: loadmore)
        collectionView.didEndDeceleratingPublisher
            .sink { [weak self] in
                self?.didEndDecelerating()
            }
            .store(in: &subscriptions)
    }
    
    open func dataDidChangePublisher() -> AnyPublisher<Void, Never> {
        fatalError("Must override")
    }
    
    open func didEndDecelerating() {
        
    }
}
