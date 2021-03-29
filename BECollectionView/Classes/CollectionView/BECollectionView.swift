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
        defer {sections.forEach {$0.collectionView = self}}
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
        sections.map {$0.layout}.forEach {$0.registerCellAndSupplementaryViews(in: collectionView)}
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
        dataDidChangeObservable()
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] (_) in
                if let snapshot = self?.mapDataToSnapshot() {
                    self?.dataSource.apply(snapshot)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.dataDidLoad()
                }
            })
            .disposed(by: disposeBag)
        
        // TODO: Loadmore
        collectionView.rx.didEndDecelerating
            .subscribe(onNext: { [unowned self] in
                // Load more
                guard self.dataSource.numberOfSections(in: self.collectionView) == 1,
                      let viewModel = self.sections.first?.viewModel,
                      viewModel.isPaginationEnabled
                else {
                    return
                }
                
                if self.collectionView.contentOffset.y > 0 {
                    let numberOfSections = self.collectionView.numberOfSections
                    guard numberOfSections > 0 else {return}

                    guard let indexPath = self.collectionView.indexPathsForVisibleItems.filter({$0.section == numberOfSections - 1}).max(by: {$0.row < $1.row})
                    else {
                        return
                    }

                    if indexPath.row >= self.collectionView.numberOfItems(inSection: self.collectionView.numberOfSections - 1) - 5 {
                        viewModel.fetchNext()
                    }
                }
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
            self?.configureSupplementaryView(collectionView: collectionView, kind: kind, indexPath: indexPath)
        }
    }
    
    func configureSupplementaryView(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            return sections[indexPath.section].configureHeader(indexPath: indexPath)
        }
        if kind == UICollectionView.elementKindSectionFooter {
            return sections[indexPath.section].configureFooter(indexPath: indexPath)
        }
        return nil
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
    
    func dataDidLoad() {
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
