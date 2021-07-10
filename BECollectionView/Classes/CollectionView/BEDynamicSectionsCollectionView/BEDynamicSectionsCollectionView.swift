//
//  BEDynamicSectionsCollectionView.swift
//  BECollectionView
//
//  Created by Chung Tran on 09/07/2021.
//

import Foundation
import RxSwift

open class BEDynamicSectionsCollectionView: BECollectionViewBase {
    // MARK: - Nested type
    public struct SectionInfo {
        public init(userInfo: AnyHashable, layout: BECollectionViewSectionBase, items: [AnyHashable]) {
            self.userInfo = userInfo
            self.layout = layout
            self.items = items
        }
        
        public let userInfo: AnyHashable
        var layout: BECollectionViewSectionBase
        let items: [AnyHashable]
    }
    
    // MARK: - Dependencies
    public let viewModel: BEListViewModelType
    private let mapDataToSections: (BEListViewModelType) -> [SectionInfo]
    private let layout: BECollectionViewSectionLayout
    
    // MARK: - Properties
    public private(set) var sections = [SectionInfo]()
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        viewModel: BEListViewModelType,
        mapDataToSections: @escaping (BEListViewModelType) -> [SectionInfo],
        layout: BECollectionViewSectionLayout,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.viewModel = viewModel
        self.mapDataToSections = mapDataToSections
        self.layout = layout
        super.init(header: header, footer: footer)
    }
    
    override func createLayout() -> UICollectionViewLayout {
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
    override func setUp() {
        super.setUp()
        setUpDataSource(
            cellProvider: { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
                self?.layout.configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
            },
            supplementaryViewProvider: { [weak self] collectionView, kind, indexPath in
                guard let strongSelf = self else {return nil}
                return strongSelf.layout.configureSupplementaryView(in: collectionView, kind: kind, indexPath: indexPath)
            }
        )
    }
    
    override func registerCellsAndSupplementaryViews() {
        super.registerCellsAndSupplementaryViews()
        layout.registerCellsAndSupplementaryViews(in: collectionView)
    }
    
    open override func dataDidChangeObservable() -> Observable<Void> {
        viewModel.dataDidChange.map {_ in ()}
    }
    
    // MARK: - Datasource
    open override func mapDataToSnapshot() -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        // get super
        var snapshot = super.mapDataToSnapshot()
        
        // map sections
        sections = mapDataToSections(viewModel).map { [weak self] section -> SectionInfo in
            var section = section
            let layout = section.layout
            layout.collectionView = self
            section.layout = layout
            return section
        }
        sections.forEach {$0.layout.registerCellAndSupplementaryViews()}
        
        // add sections
        let sectionsHeaders = sections.map {$0.userInfo}
        snapshot.appendSections(sectionsHeaders)
        
        // add items into sections
        for section in sections {
            let items = section.items
                .map {BECollectionViewItem(value: $0)}
            snapshot.appendItems(items, toSection: section.userInfo)
        }
        
        switch viewModel.currentState {
        case .loading, .initializing:
            let items = [
                BECollectionViewItem(placeholderIndex: UUID().uuidString),
                BECollectionViewItem(placeholderIndex: UUID().uuidString)
            ]
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
    
    // MARK: - Action
    open override func didEndDecelerating() {
        super.didEndDecelerating()
        // get indexPaths
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        // Loadmore
        guard sections.count > 0 else {return}
        if visibleIndexPaths.map {$0.section}.max() == sections.count - 1,
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
