//
//  BECollectionView.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import PureLayout
import RxSwift

@available(*, deprecated, renamed: "BEStaticSectionCollectionView")
open class BECollectionView: BEStaticSectionsCollectionView {}

open class BEStaticSectionsCollectionView: BECollectionViewBase {
    // MARK: - Properties
    public let sections: [Section]
    
    // MARK: - Initializers
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        sections: [Section],
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.sections = sections
        super.init(header: header, footer: footer)
    }
    
    override func setUp() {
        sections.forEach {$0.collectionView = self}
        super.setUp()
        setUpDataSource { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
            self?.sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
        }
    }
    
    override func registerCellsAndSupplementaryViews() {
        super.registerCellsAndSupplementaryViews()
        sections.forEach {$0.registerCellAndSupplementaryViews()}
    }
    
    // MARK: - Binding
    open override func dataDidChangeObservable() -> Observable<Void> {
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
    
    // MARK: - Layout
    override func createLayout() -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self?.sections[sectionIndex].layout.layout(environment: env)
        }, configuration: config)
        
        for section in sections where section.layout.background != nil {
            layout.register(section.layout.background.self, forDecorationViewOfKind: String(describing: section.layout.background!))
        }
        return layout
    }
    
    // MARK: - Datasource
    override func supplementaryViewProvider(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        if let view = super.supplementaryViewProvider(kind: kind, indexPath: indexPath) {
            return view
        }
        return sections[indexPath.section].configureSupplementaryView(kind: kind, indexPath: indexPath)
    }
    
    // MARK: - Actions
    open override func refresh() {
        super.refresh()
        refreshAllSections()
    }
    
    open func refreshAllSections() {
        sections.forEach {$0.reload()}
    }
    
    open override func reloadData(completion: @escaping () -> Void) {
        let snapshot = mapDataToSnapshot()
        dataSource.apply(snapshot, animatingDifferences: true, completion: completion)
    }
    
    open override func dataDidLoad() {
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
        super.dataDidLoad()
        sections.forEach {$0.dataDidLoad()}
    }
    
    open override func didEndDecelerating() {
        super.didEndDecelerating()
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
