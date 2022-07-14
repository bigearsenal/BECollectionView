//
//  BECollectionViewBase.swift
//  BECollectionView
//
//  Created by Chung Tran on 09/07/2021.
//

import Foundation
import PureLayout
import RxSwift
import UIKit
import BECollectionView_Core

open class BECollectionViewBase: UIView {
    // MARK: - Constants
    private let headerIdentifier = "GlobalHeaderIdentifier"
    private let footerIdentifier = "GlobalFooterIdentifier"
    
    // MARK: - Property
    let disposeBag = DisposeBag()
    public let header: BECollectionViewHeaderFooterViewLayout?
    public let footer: BECollectionViewHeaderFooterViewLayout?
    
    public var canRefresh: Bool = true {
        didSet {
            setUpRefreshControl()
        }
    }
    
    public internal(set) var dataSource: UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>!
    public weak var delegate: BECollectionViewDelegate?

    private let scrollDelegateAdapter = BECollectionViewScrollDelegateAdapter()

    public var scrollDelegate: UIScrollViewDelegate? {
        get {
            scrollDelegateAdapter.realScrollDelegate
        }
        set {
            scrollDelegateAdapter.realScrollDelegate = newValue
        }
    }
    
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewDidTouch(_:)))
        collectionView.addGestureRecognizer(tapGesture)
        return collectionView
    }()
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.header = header
        self.footer = footer
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
        collectionView.delegate = scrollDelegateAdapter
        collectionView.autoPinEdgesToSuperviewEdges()
        setUpRefreshControl()
        
        // register cell and configure datasource
        setUp()
        
        // binding
        bind()
    }
    
    func createLayout() -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            nil
        }, configuration: config)
        return layout
    }
    
    // MARK: - Set up
    open override func layoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
        super.layoutSubviews()
    }
    
    func setUp() {
        registerCellsAndSupplementaryViews()
    }
    
    func registerCellsAndSupplementaryViews() {
        if let header = header {
            collectionView.register(
                header.viewType,
                forSupplementaryViewOfKind: headerIdentifier,
                withReuseIdentifier: headerIdentifier
            )
        }
        if let footer = footer {
            collectionView.register(
                footer.viewType,
                forSupplementaryViewOfKind: footerIdentifier,
                withReuseIdentifier: footerIdentifier
            )
        }
    }
    
    func setUpDataSource(
        cellProvider: @escaping UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>.CellProvider,
        supplementaryViewProvider: UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>.SupplementaryViewProvider?
    ) {
        dataSource = UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>(collectionView: collectionView, cellProvider: cellProvider)
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if kind == self?.headerIdentifier {
                return self?.configureHeaderView(kind: kind, indexPath: indexPath)
            }
            if kind == self?.footerIdentifier {
                return self?.configureFooterView(kind: kind, indexPath: indexPath)
            }
            
            return supplementaryViewProvider?(collectionView, kind, indexPath)
        }
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
    
    // MARK: - Layout
    open func compositionalLayoutConfiguration() -> UICollectionViewCompositionalLayoutConfiguration {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        // header
        var items = [NSCollectionLayoutBoundarySupplementaryItem]()
        if let header = header {
            let globalHeaderSize = NSCollectionLayoutSize(
                widthDimension: header.widthDimension,
                heightDimension: header.heightDimension
            )
            let globalHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: globalHeaderSize,
                elementKind: headerIdentifier,
                alignment: .top
            )
            items.append(globalHeader)
        }
        
        // footer
        if let footer = footer {
            let globalFooterSize = NSCollectionLayoutSize(
                widthDimension: footer.widthDimension,
                heightDimension: footer.heightDimension
            )
            let globalFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: globalFooterSize,
                elementKind: footerIdentifier,
                alignment: .bottom
            )
            items.append(globalFooter)
        }
        
        // add supplementaryItems
        if items.count != 0 {
            config.boundarySupplementaryItems = items
        }
        
        return config
    }
    
    open func configureHeaderView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        collectionView.dequeueReusableSupplementaryView(ofKind: headerIdentifier, withReuseIdentifier: headerIdentifier, for: indexPath)
    }
    
    open func configureFooterView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        collectionView.dequeueReusableSupplementaryView(ofKind: footerIdentifier, withReuseIdentifier: footerIdentifier, for: indexPath)
    }
    
    // MARK: - Actions
    @objc open func refresh() {
        collectionView.refreshControl?.endRefreshing()
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
        }
    }
    
    open func didEndDecelerating() {
        
    }
    
    open func reloadData(completion: @escaping () -> Void) {
        let snapshot = mapDataToSnapshot()
        dataSource.apply(snapshot, animatingDifferences: true, completion: completion)
    }
    
    open func mapDataToSnapshot() -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        let snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
        return snapshot
    }
    
    open func dataDidLoad() {
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
