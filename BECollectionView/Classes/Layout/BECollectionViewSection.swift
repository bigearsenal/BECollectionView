//
//  BECollectionViewSection.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift

open class BECollectionViewSection {
    public weak var collectionView: BECollectionView?
    public let layout: BECollectionViewSectionLayout
    public let viewModel: BEListViewModelType
    
    public init(layout: BECollectionViewSectionLayout, viewModel: BEListViewModelType)
    {
        self.layout = layout
        self.viewModel = viewModel
    }
    
    func mapDataToCollectionViewItems() -> [BECollectionViewItem]
    {
        var items = viewModel.convertDataToAnyHashable()
            .map {BECollectionViewItem(value: $0)}
        switch viewModel.currentState {
        case .loading:
            items += [
                BECollectionViewItem(placeholderIndex: UUID().uuidString),
                BECollectionViewItem(placeholderIndex: UUID().uuidString)
            ]
        case .loaded, .error, .initializing:
            break
        }
        return items
    }
    
    open func dataDidLoad() {
        
    }
}

extension Array where Element == BECollectionViewSection {
    func createLayout(interSectionSpacing: CGFloat? = nil) -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        if let interSectionSpacing = interSectionSpacing {
            config.interSectionSpacing = interSectionSpacing
        }
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self.createLayoutForSection(sectionIndex, environment: env)
        }, configuration: config)
        
        for section in self where section.layout.background != nil {
            layout.register(section.layout.background.self, forDecorationViewOfKind: String(describing: section.layout.background!))
        }
        
        return layout
    }
    
    func createLayoutForSection(_ sectionIndex: Int, environment env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let section = self[sectionIndex]
        return section.layout.layout(environment: env)
    }
}
