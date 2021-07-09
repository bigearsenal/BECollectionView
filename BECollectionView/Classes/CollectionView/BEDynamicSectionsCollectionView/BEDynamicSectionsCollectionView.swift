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
        var layout: BECollectionViewSectionBase
        let items: [AnyHashable]
    }
    
    // MARK: - Properties
    public let viewModel: BEListViewModelType
    private let mapDataToSections: (BEListViewModelType) -> [SectionInfo]
    private let emptySection: BECollectionViewSectionBase
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        viewModel: BEListViewModelType,
        mapDataToSections: @escaping (BEListViewModelType) -> [SectionInfo],
        emptySection: BECollectionViewSectionBase,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.viewModel = viewModel
        self.mapDataToSections = mapDataToSections
        self.emptySection = emptySection
        super.init(header: header, footer: footer)
    }
    
    open override func dataDidChangeObservable() -> Observable<Void> {
        viewModel.dataDidChange.map {_ in ()}
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    }
    
    // MARK: - Set up
    override func setUp() {
        emptySection.collectionView = self
        super.setUp()
        setUpDataSource(cellProvider: {_,_,_  in nil}, supplementaryViewProvider: nil)
    }
    
    override func registerCellsAndSupplementaryViews() {
        super.registerCellsAndSupplementaryViews()
        emptySection.registerCellAndSupplementaryViews()
    }
    
    // MARK: - Action
    open override func reloadData(completion: @escaping () -> Void) {
        // map sections
        let sections = mapDataToSections(viewModel).map { [weak self] section -> SectionInfo in
            var section = section
            let layout = section.layout
            layout.collectionView = self
            section.layout = layout
            return section
        }
        
        // register cells and supplementary views
        
        sections.forEach {$0.layout.registerCellAndSupplementaryViews()}
        
        // createLayout
        let layout = createLayout(sections: sections.map {$0.layout})
        
        // apply layout and snapshot
        collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] flag in
            guard flag, let strongSelf = self else {return}
            // configure data source
            strongSelf.setUpDataSource(
                cellProvider: { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell? in
                    let section = sections[safe: indexPath.section]?.layout ?? self?.emptySection
                    return section?.configureCell(collectionView: collectionView, indexPath: indexPath, item: item)
                },
                supplementaryViewProvider: { [weak self] collectionView, kind, indexPath in
                    let section = sections[safe: indexPath.section]?.layout ?? self?.emptySection
                    return section?.configureSupplementaryView(kind: kind, indexPath: indexPath)
                }
            )
            
            // map snapshot
            let snapshot = strongSelf.mapDataToSnapshot(sections: sections)
            strongSelf.dataSource.apply(snapshot, animatingDifferences: true, completion: completion)
        }
    }
    
    func createLayout(sections: [BECollectionViewSectionBase]) -> UICollectionViewLayout {
        let config = compositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section = sections[safe: sectionIndex] ?? self?.emptySection
            return section?.layout.layout(environment: env)
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
            if sections.allSatisfy({$0.items.isEmpty}) {
                if emptySection.layout.emptyCellType != nil {
                    let items = [BECollectionViewItem(emptyCellIndex: UUID().uuidString)]
                    snapshot.appendSections([0])
                    snapshot.appendItems(items, toSection: 0)
                }
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

private extension Array {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
