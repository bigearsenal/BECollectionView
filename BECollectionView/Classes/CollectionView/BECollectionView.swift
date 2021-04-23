//
//  BECollectionView.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import PureLayout
import RxSwift

open class BECollectionView: UIView {
    // MARK: - Property
    private let disposeBag = DisposeBag()
    public let sections: [BECollectionViewSection]
    public var canRefresh: Bool = true {
        didSet {
            setUpRefreshControl()
        }
    }
    public private(set) var dataSource: UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>!
    public weak var delegate: BECollectionViewDelegate?
    
    public var contentInset: UIEdgeInsets {
        get {
            collectionView.contentInset
        }
        set {
            collectionView.contentInset = newValue
        }
    }
    
    public var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
        get {
            collectionView.keyboardDismissMode
        }
        set {
            collectionView.keyboardDismissMode = newValue
        }
    }
    
    // MARK: - Subviews
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: sections.createLayout())
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewDidTouch(_:)))
        collectionView.addGestureRecognizer(tapGesture)
        return collectionView
    }()
    
    // MARK: - Initializer
    public init(sections: [BECollectionViewSection]) {
        self.sections = sections
        super.init(frame: .zero)
        commonInit()
    }
    
    @available(*, unavailable,
    message: "Loading this view from a nib is unsupported in favor of initializer dependency injection."
    )
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        // add subviews
        addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.autoPinEdgesToSuperviewEdges()
        setUpRefreshControl()
        
        // register cell and configure datasource
        sections.forEach {$0.collectionView = self}
        sections.forEach {$0.registerCellAndSupplementaryViews()}
        configureDataSource()
        
        // binding
        bind()
    }
    
    private func setUpRefreshControl() {
        if canRefresh {
            let control = UIRefreshControl()
            control.addTarget(self, action: #selector(refresh), for: .valueChanged)
            collectionView.refreshControl = control
        } else {
            collectionView.refreshControl = nil
        }
    }
    
    open func bind() {
        var observable = dataDidChangeObservable()
        
        if SystemVersion.isIOS13() {
            observable = observable
                .debounce(.nanoseconds(1), scheduler: MainScheduler.instance)
        }
        
        observable
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                let snapshot = self.mapDataToSnapshot()
                self.dataSource.apply(snapshot)
                DispatchQueue.main.async { [weak self] in
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
        Observable<Void>.combineLatest(
            sections.map {$0.viewModel.dataDidChange}
        )
            .map {_ in ()}
    }
    
    open func mapDataToSnapshot() -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        var snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
        let sectionsHeaders = self.sections.indices.map {$0}
        snapshot.appendSections(sectionsHeaders)
        
        for (index, section) in sections.enumerated() {
            let items = section.mapDataToCollectionViewItems()
            snapshot.appendItems(items, toSection: sectionsHeaders[index])
        }
        return snapshot
    }
    
    // MARK: - Datasource
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
            self?.sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
        }
                
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            self?.sections[indexPath.section].configureSupplementaryView(kind: kind, indexPath: indexPath)
        }
    }
    
    // MARK: - Actions
    @objc open func refresh() {
        collectionView.refreshControl?.endRefreshing()
        refreshAllSections()
    }
    
    open func refreshAllSections() {
        sections.forEach {$0.reload()}
    }
    
    @objc private func collectionViewDidTouch(_ sender: UIGestureRecognizer) {
        if let indexPath = collectionView.indexPathForItem(at: sender.location(in: collectionView)) {
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else {return}
            if item.isPlaceholder {
                return
            }
            if let item = item.value {
                delegate?.beCollectionView?(collectionView: self, didSelect: item)
            }
        } else {
            print("collection view was tapped")
        }
    }
    
    open func dataDidLoad() {
//        let numberOfSections = dataSource.numberOfSections(in: collectionView)
//        guard numberOfSections > 0,
//              let footer = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: numberOfSections - 1)) as? SectionFooterView
//        else {
//            return
//        }
//
//        footer.setUp(state: viewModel.state.value, isListEmpty: viewModel.isListEmpty)
////        collectionView.collectionViewLayout.invalidateLayout()
//        footer.setNeedsDisplay()
        sections.forEach {$0.dataDidLoad()}
        delegate?.beCollectionViewDataDidLoad?(collectionView: self)
    }
    
    open func didEndDecelerating() {
        // get indexPaths
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        // Loadmore
        let sectionIndexes = Array(Set(visibleIndexPaths.map {$0.section}))
        
        for index in sectionIndexes {
            
            let section = self.sections[index]
            let viewModel = section.viewModel
            
            let lastVisibleRowIndex = visibleIndexPaths
                .filter {$0.section == index}
                .max(by: {$0.row < $1.row})?
                .row ?? -1
            
            if viewModel.isPaginationEnabled,
               collectionView.contentOffset.y > 0,
               lastVisibleRowIndex >= collectionView.numberOfItems(inSection: index) - 5
            {
                viewModel.fetchNext()
            }
        }
    }
    
    // MARK: - Helpers
    public func sectionHeaderView(sectionIndex: Int) -> UICollectionReusableView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: sectionIndex))
    }
    
    public func sectionFooterView(sectionIndex: Int) -> UICollectionReusableView? {
        collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: sectionIndex))
    }
    
    public func relayout(_ context: UICollectionViewLayoutInvalidationContext? = nil) {
        if let context = context {
            collectionView.collectionViewLayout.invalidateLayout(with: context)
        } else {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

public extension NSDiffableDataSourceSnapshot where SectionIdentifierType: Hashable, ItemIdentifierType == BECollectionViewItem
{
    func isSectionEmpty(sectionIdentifier: SectionIdentifierType) -> Bool {
        let itemsCount = numberOfItems(inSection: sectionIdentifier)
        if itemsCount == 1,
           let firstItem = itemIdentifiers(inSection: sectionIdentifier)
            .first,
           firstItem.isEmptyCell
        {
            return true
        }
        return itemsCount == 0
    }
}
