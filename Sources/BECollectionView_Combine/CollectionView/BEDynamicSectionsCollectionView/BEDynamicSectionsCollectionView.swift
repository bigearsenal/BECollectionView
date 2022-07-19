import Foundation
import UIKit
import Combine
import BECollectionView_Core

open class BEDynamicSectionsCollectionView: BECollectionViewBaseCombine {
    // MARK: - Nested type
    public struct SectionInfo {
        public init(userInfo: AnyHashable, items: [AnyHashable], customLayout: BECollectionViewSectionLayout? = nil) {
            self.userInfo = userInfo
            self.customLayout = customLayout
            self.items = items
        }
        
        public let userInfo: AnyHashable
        let customLayout: BECollectionViewSectionLayout?
        let items: [AnyHashable]
    }
    
    // MARK: - Dependencies
    public let viewModel: BECollectionViewModelType
    private let mapDataToSections: (BECollectionViewModelType) -> [SectionInfo]
    private let layout: BECollectionViewSectionLayout
    
    // MARK: - Properties
    public private(set) var sections = [SectionInfo]()
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        viewModel: BECollectionViewModelType,
        mapDataToSections: @escaping (BECollectionViewModelType) -> [SectionInfo],
        layout: BECollectionViewSectionLayout,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.viewModel = viewModel
        self.mapDataToSections = mapDataToSections
        self.layout = layout
        super.init(header: header, footer: footer)
    }
    
    
    
    open override func createLayout() -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self?.layout.layout(environment: env)
        }, configuration: config)
        
        if let background = self.layout.background {
            layout.register(background.self, forDecorationViewOfKind: String(describing: background))
        }
        
        return layout
    }
    
    // MARK: - Set up
    open override func setUp() {
        super.setUp()
        setUpDataSource(
            cellProvider: { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
                self?.configureCell(indexPath: indexPath, item: item)
            },
            supplementaryViewProvider: { [weak self] collectionView, kind, indexPath in
                self?.configureSupplementaryViews(kind: kind, indexPath: indexPath)
            }
        )
    }
    
    open override func registerCellsAndSupplementaryViews() {
        super.registerCellsAndSupplementaryViews()
        
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Empty")
        
        layout.registerCellsAndSupplementaryViews(in: collectionView)
    }
    
    open override func dataDidChangePublisher() -> AnyPublisher<Void, Never> {
        viewModel.dataDidChange.map {_ in ()}.eraseToAnyPublisher()
    }
    
    // MARK: - Datasource
    open override func mapDataToSnapshot() -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        // get super
        var snapshot = super.mapDataToSnapshot()
        
        // map sections
        sections = mapDataToSections(viewModel)
        sections.forEach {$0.customLayout?.registerCellsAndSupplementaryViews(in: collectionView)}
        
        // add sections
        let sectionsHeaders = sections.map {$0.userInfo}
        snapshot.appendSections(sectionsHeaders)
        
        // add items into sections
        for section in sections {
            let items = section.items
                .map {BECollectionViewItem(value: $0)}
            snapshot.appendItems(items, toSection: section.userInfo)
        }
        
        switch viewModel.state {
        case .loading, .initializing:
            var items = [BECollectionViewItem]()
            for _ in 0..<layout.numberOfLoadingCells {
                items.append(BECollectionViewItem(placeholderIndex: UUID().uuidString))
            }
            snapshot.appendSections(["placeholder"])
            snapshot.appendItems(items, toSection: "placeholder")
        case .loaded:
            if sections.allSatisfy({$0.items.isEmpty}) {
                let items = [BECollectionViewItem(emptyCellIndex: UUID().uuidString)]
                snapshot = .init()
                snapshot.appendSections(["empty"])
                snapshot.appendItems(items, toSection: "empty")
            }
        case .error:
            break
        }
        return snapshot
    }
    
    func configureSupplementaryViews(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        var layout = self.layout
        if let customLayout = sections[safe: indexPath.section]?.customLayout {
            layout = customLayout
        }
        let view = layout.configureSupplementaryView(in: collectionView, kind: kind, indexPath: indexPath)
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section >= sections.count {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Empty", for: indexPath)
            }
            configureSectionHeaderView(view: view, sectionIndex: indexPath.section)
        }
        if kind == UICollectionView.elementKindSectionFooter {
            configureSectionFooterView(view: view, sectionIndex: indexPath.section)
        }
        return view
    }
    
    open func configureSectionHeaderView(view: UICollectionReusableView?, sectionIndex: Int) {
        
    }
    
    open func configureSectionFooterView(view: UICollectionReusableView?, sectionIndex: Int) {
        
    }
    
    open func configureCell(indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? {
        var layout = self.layout
        if let customLayout = sections[safe: indexPath.section]?.customLayout {
            layout = customLayout
        }
        return layout.configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
    }
    
    // MARK: - Action
    open override func didEndDecelerating() {
        super.didEndDecelerating()
        // get indexPaths
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        // Loadmore
        guard sections.count > 0 else {return}
        if visibleIndexPaths.map({$0.section}).max() == sections.count - 1,
           viewModel.isPaginationEnabled,
           collectionView.contentOffset.y > 0
        {
            viewModel.fetchNext()
        }
    }
    
    open override func refresh() {
        super.refresh()
        viewModel.reload()
    }
}

private extension Array {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
