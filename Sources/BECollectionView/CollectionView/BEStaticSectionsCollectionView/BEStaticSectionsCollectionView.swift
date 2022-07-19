//
//  BECollectionView.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import UIKit
import RxSwift
import BECollectionView_Core

open class BEStaticSectionsCollectionView: BECollectionViewBaseRx {
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
    
    open override func createLayout() -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self?.sections[sectionIndex].layout.layout(environment: env)
        }, configuration: config)
        
        for section in sections where section.layout.background != nil {
            layout.register(section.layout.background.self, forDecorationViewOfKind: String(describing: section.layout.background!))
        }
        return layout
    }
    
    // MARK: - Set up
    open override func setUp() {
        super.setUp()
        setUpDataSource(
            cellProvider: { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
                self?.sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
            },
            supplementaryViewProvider: {[weak self] collectionView, kind, indexPath in
                self?.sections[indexPath.section].configureSupplementaryView(kind: kind, indexPath: indexPath)
            }
        )
    }
    
    open override func registerCellsAndSupplementaryViews() {
        super.registerCellsAndSupplementaryViews()
        sections.forEach {$0.collectionView = self}
        sections.forEach {$0.registerCellAndSupplementaryViews()}
    }
    
    // MARK: - Binding
    open override func dataDidChangeObservable() -> Observable<Void> {
        Observable<Void>.combineLatest(
            sections.map {$0.viewModel.dataDidChange}
        )
            .map {_ in ()}
    }
    
    open override func mapDataToSnapshot() -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        var snapshot = super.mapDataToSnapshot()
        let sectionsHeaders = self.sections.indices.map {sectionIdentifier(sectionIndex: $0)}
        snapshot.appendSections(sectionsHeaders)
        
        for (index, section) in sections.enumerated() {
            let items = section.mapDataToCollectionViewItems()
            snapshot.appendItems(items, toSection: sectionsHeaders[index])
        }
        return snapshot
    }
    
    open func sectionIdentifier(sectionIndex: Int) -> AnyHashable {
        sectionIndex
    }
    
    // MARK: - Actions
    open override func refresh() {
        super.refresh()
        refreshAllSections()
    }
    
    open func refreshAllSections() {
        sections.forEach {$0.reload()}
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
