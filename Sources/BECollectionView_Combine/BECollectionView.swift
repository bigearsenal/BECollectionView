import Foundation
import Combine
import CombineCocoa
import UIKit
import BECollectionView_Core

open class BECollectionView: UICollectionView {
    // MARK: - Constants
    private static let headerIdentifier = "GlobalHeaderIdentifier"
    private static let footerIdentifier = "GlobalFooterIdentifier"
    
    // MARK: - Properties
    public let header: BECollectionViewHeaderFooterViewLayout?
    public let footer: BECollectionViewHeaderFooterViewLayout?
    
    private var subscriptions = [AnyCancellable]()
    
    public var canRefresh: Bool = true {
        didSet {
            setUpRefreshControl()
        }
    }
    
    private let scrollDelegateAdapter = BECollectionViewScrollDelegateAdapter()
    
    public var scrollDelegate: UIScrollViewDelegate? {
        get { scrollDelegateAdapter.realScrollDelegate }
        set { scrollDelegateAdapter.realScrollDelegate = newValue }
    }
    
    open override var dataSource: UICollectionViewDataSource? {
        get { diffableDataSource }
        set { fatalError("dataSource is read-only from outside") }
    }
    
    public internal(set) var diffableDataSource: UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>!
    
    public var dataDidLoadHandler: (() -> Void)?
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.header = header
        self.footer = footer
        super.init(frame: .zero, collectionViewLayout: Self.createLayout())
        commonInit()
    }
    
    @available(*, unavailable,
    message: "Loading this view from a nib is unsupported in favor of initializer dependency injection."
    )
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        // set up refreshControl
        setUpRefreshControl()
        
        // register cell and configure datasource
        setUp()
        
        // binding
        bind()
    }
    
    // MARK: - Set up
    open override func layoutSubviews() {
        collectionViewLayout.invalidateLayout()
        super.layoutSubviews()
    }
    
    func setUp() {
        registerCellsAndSupplementaryViews()
    }
    
    func registerCellsAndSupplementaryViews() {
        if let header = header {
            register(
                header.viewType,
                forSupplementaryViewOfKind: Self.headerIdentifier,
                withReuseIdentifier: Self.headerIdentifier
            )
        }
        if let footer = footer {
            register(
                footer.viewType,
                forSupplementaryViewOfKind: Self.footerIdentifier,
                withReuseIdentifier: Self.footerIdentifier
            )
        }
    }
    
    func setUpDataSource(
        cellProvider: @escaping UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>.CellProvider,
        supplementaryViewProvider: UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>.SupplementaryViewProvider?
    ) {
        diffableDataSource = UICollectionViewDiffableDataSource<AnyHashable, BECollectionViewItem>(collectionView: self, cellProvider: cellProvider)
        
        diffableDataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if kind == Self.headerIdentifier {
                return self?.configureHeaderView(kind: kind, indexPath: indexPath)
            }
            if kind == Self.footerIdentifier {
                return self?.configureFooterView(kind: kind, indexPath: indexPath)
            }
            
            return supplementaryViewProvider?(collectionView, kind, indexPath)
        }
    }
    
    private func setUpRefreshControl() {
        if canRefresh {
            let control = UIRefreshControl()
            control.addTarget(self, action: #selector(refresh), for: .valueChanged)
            refreshControl = control
        } else {
            refreshControl = nil
        }
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
                    self?.dataDidLoadHandler?()
                }
            }
            .store(in: &subscriptions)
        
        // did end decelerating (ex: loadmore)
        didEndDeceleratingPublisher
            .sink { [weak self] in
                self?.didEndDecelerating()
            }
            .store(in: &subscriptions)
    }
    
    open func dataDidChangePublisher() -> AnyPublisher<Void, Never> {
        fatalError("Must override")
    }
    
    // MARK: - Layout
    private class func createLayout() -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            nil
        }, configuration: config)
        return layout
    }
    
    open class func compositionalLayoutConfiguration(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) -> UICollectionViewCompositionalLayoutConfiguration {
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
        dequeueReusableSupplementaryView(ofKind: Self.headerIdentifier, withReuseIdentifier: Self.headerIdentifier, for: indexPath)
    }
    
    open func configureFooterView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        dequeueReusableSupplementaryView(ofKind: Self.footerIdentifier, withReuseIdentifier: Self.footerIdentifier, for: indexPath)
    }
    
    // MARK: - Actions
    @objc open func refresh() {
        refreshControl?.endRefreshing()
    }
    
    open func reloadData(completion: @escaping () -> Void) {
        let snapshot = mapDataToSnapshot()
        diffableDataSource.apply(snapshot, animatingDifferences: true, completion: completion)
    }
    
    open func didEndDecelerating() {}
    
    open func mapDataToSnapshot() -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        let snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
        return snapshot
    }
    
    // MARK: - Helpers
    public func sectionHeaderView(sectionIndex: Int) -> UICollectionReusableView? {
        supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: sectionIndex))
    }
    
    public func sectionFooterView(sectionIndex: Int) -> UICollectionReusableView? {
        supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: sectionIndex))
    }
    
    public func relayout(_ context: UICollectionViewLayoutInvalidationContext? = nil) {
        if let context = context {
            collectionViewLayout.invalidateLayout(with: context)
        } else {
            collectionViewLayout.invalidateLayout()
        }
    }
}
