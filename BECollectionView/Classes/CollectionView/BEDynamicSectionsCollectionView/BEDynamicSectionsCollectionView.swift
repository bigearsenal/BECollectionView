//
//  BEDynamicSectionsCollectionView.swift
//  BECollectionView
//
//  Created by Chung Tran on 09/07/2021.
//

import Foundation
import RxSwift

open class BEDynamicSectionsCollectionView: BECollectionViewBase {
    public struct SectionInfo {
        public init(userInfo: AnyHashable, layout: BECollectionViewSectionBase, items: [AnyHashable]) {
            self.userInfo = userInfo
            self.layout = layout
            self.items = items
        }
        
        let userInfo: AnyHashable
        let layout: BECollectionViewSectionBase
        let items: [AnyHashable]
    }
    
    // MARK: - Properties
    public let viewModel: BEListViewModelType
    private let mapDataToSections: (BEListViewModelType) -> [SectionInfo]
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        viewModel: BEListViewModelType,
        mapDataToSections: @escaping (BEListViewModelType) -> [SectionInfo],
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.viewModel = viewModel
        self.mapDataToSections = mapDataToSections
        super.init(header: header, footer: footer)
    }
    
    open override func dataDidChangeObservable() -> Observable<Void> {
        viewModel.dataDidChange.map {_ in ()}
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    }
    
    // MARK: - Action
    open override func reloadData(completion: @escaping () -> Void) {
        // map sections
        let sections = mapDataToSections(viewModel)
        
        // register cells and supplementary views
        sections.forEach {$0.layout.registerCellAndSupplementaryViews()}
        
        // createLayout
        let layout = createLayout(sections: sections.map {$0.layout})
        
        // apply layout and snapshot
        collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] flag in
            guard flag, let strongSelf = self else {return}
            let snapshot = strongSelf.mapDataToSnapshot(sections: sections)
            strongSelf.dataSource.apply(snapshot, animatingDifferences: true, completion: completion)
        }
    }
    
    func createLayout(sections: [BECollectionViewSectionBase]) -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            sections[sectionIndex].layout.layout(environment: env)
        }, configuration: config)
        
        for section in sections where section.layout.background != nil {
            layout.register(section.layout.background.self, forDecorationViewOfKind: String(describing: section.layout.background!))
        }
        return layout
    }
    
    open func mapDataToSnapshot(sections: [SectionInfo]) -> NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem> {
        var snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
        
        switch viewModel.currentState {
        case .loading, .initializing:
            let items = [
                BECollectionViewItem(placeholderIndex: UUID().uuidString),
                BECollectionViewItem(placeholderIndex: UUID().uuidString)
            ]
            snapshot.appendSections([0])
            snapshot.appendItems(items, toSection: 0)
        case .loaded:
            if sections.allSatisfy({$0.items.isEmpty}), sections.first?.layout.layout.emptyCellType != nil {
                let items = [BECollectionViewItem(emptyCellIndex: UUID().uuidString)]
                snapshot.appendSections([0])
                snapshot.appendItems(items, toSection: 0)
            } else {
                let sectionsHeaders = sections.map {$0.userInfo}
                snapshot.appendSections(sectionsHeaders)
                
                for section in sections {
                    let items = section.items
                        .map {BECollectionViewItem(value: $0)}
                    snapshot.appendItems(items, toSection: section.userInfo)
                }
            }
        case .error:
            break
        }
        return snapshot
    }
    
    open override func refresh() {
        super.refresh()
        viewModel.reload()
    }
}
