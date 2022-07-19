import Foundation
import RxSwift
import BECollectionView_Core

open class BECollectionViewBaseRx: BECollectionViewBase {
    let disposeBag = DisposeBag()
    
    open override func commonInit() {
        super.commonInit()
        bind()
    }
    
    // MARK: - Binding
    open func bind() {
        var observable = dataDidChangeObservable()
        
        if SystemVersion.isIOS13() {
            observable = observable
                .debounce(.nanoseconds(1), scheduler: MainScheduler.instance)
        }
        
        observable
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.reloadData { [weak self] in
                    self?.dataDidLoad()
                }
            })
            .disposed(by: disposeBag)
        
        // did end decelerating (ex: loadmore)
        collectionView.rx.didEndDecelerating
            .subscribe(onNext: { [weak self] in
                self?.didEndDecelerating()
            })
            .disposed(by: disposeBag)
    }
    
    open func dataDidChangeObservable() -> Observable<Void> {
        fatalError("Must override")
    }
    
    open func didEndDecelerating() {
        
    }
}
