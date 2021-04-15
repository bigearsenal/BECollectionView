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
    private var sections = [BECollectionViewSection]()
    private let disposeBag = DisposeBag()
    public let viewModels: [BEListViewModelType]
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewDidTouch(_:)))
        collectionView.addGestureRecognizer(tapGesture)
        return collectionView
    }()
    
    // MARK: - Initializer
    public init(viewModels: [BEListViewModelType]) {
        self.viewModels = viewModels
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
                // register cell and configure datasource
                self.sections = self.mapDataToSections()
                
                // configure datasource
                self.configureDataSource()
                
                // reset layout
                self.collectionView.setCollectionViewLayout(self.sections.createLayout(), animated: false)
                
                // register cells and supplementary views
                for index in 0..<self.sections.count {
                    self.sections[index].collectionView = self
                }
                self.sections.forEach {$0.registerCellAndSupplementaryViews()}
                
                // map snapshot
                let snapshot = self.mapDataToSnapshot(sections: self.sections)
                self.dataSource.apply(snapshot)
                DispatchQueue.main.async { [weak self] in
                    self?.dataDidLoad()
                }
            })
            .disposed(by: disposeBag)
        
        // TODO: Loadmore
        collectionView.rx.didEndDecelerating
            .subscribe(onNext: { [weak self] in
                // Load more
                self?.handleLoadMore()
            })
            .disposed(by: disposeBag)
    }
    
    open func dataDidChangeObservable() -> Observable<Void> {
        Observable<Void>.combineLatest(
            viewModels.map {$0.dataDidChange}
        )
            .map {_ in ()}
    }
    
    open func mapDataToSections() -> [BECollectionViewSection] {
        fatalError("must override")
    }
    
    open func mapDataToSnapshot(sections: [BECollectionViewSection]) -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        // configure data source
        var snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
        let sectionsHeaders = sections.indices.map {$0}
        snapshot.appendSections(sectionsHeaders)
        
        for (index, section) in sections.enumerated() {
            let items = section.mapDataToCollectionViewItems()
            snapshot.appendItems(items, toSection: sectionsHeaders[index])
        }
        return snapshot
    }
    
    // MARK: - Datasource
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>(collectionView: collectionView) {[weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
            self?.sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
        }
                
        dataSource.supplementaryViewProvider = {[weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            self?.sections[indexPath.section].configureSupplementaryView(kind: kind, indexPath: indexPath)
        }
    }
    
    // MARK: - Actions
    @objc open func refresh() {
        collectionView.refreshControl?.endRefreshing()
        refreshAllSections()
    }
    
    open func refreshAllSections() {
        viewModels.forEach {$0.reload()}
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
    
    // MARK: - Helper
    private func handleLoadMore() {
        // get number of Sections
        let numberOfSections = dataSource.numberOfSections(in: collectionView)
        guard numberOfSections == sections.count else {return}
        
        // load more in sections
        for i in 0..<sections.count {
            // get viewModel
            let viewModel = sections[i].viewModel
            if !viewModel.isPaginationEnabled {continue}
            
            // detect visible rows
            guard let indexPath = collectionView
                    .indexPathsForVisibleItems
                    .filter({$0.section == i})
                    .max(by: {$0.row < $1.row})
            else { continue }
            
            // load more if reached last 5 items
            if indexPath.row >= self.collectionView.numberOfItems(inSection: i) - 5
            {
                viewModel.fetchNext()
            }
        }
    }
}
