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
    public let index: Int
    public let layout: BECollectionViewSectionLayout
    public let viewModel: BEListViewModelType
    public let customFilter: ((AnyHashable) -> Bool)?
    public let limit: (([AnyHashable]) -> [AnyHashable])?
    
    public init(
        index: Int,
        layout: BECollectionViewSectionLayout,
        viewModel: BEListViewModelType,
        customFilter: ((AnyHashable) -> Bool)? = nil,
        limit: (([AnyHashable]) -> [AnyHashable])? = nil
    ) {
        self.index = index
        self.layout = layout
        self.viewModel = viewModel
        self.customFilter = customFilter
        self.limit = limit
    }
    
    func mapDataToCollectionViewItems() -> [BECollectionViewItem]
    {
        var items = viewModel.convertDataToAnyHashable()
            
        if let customFilter = customFilter {
            items = items.filter {customFilter($0)}
        }
        
        if let limit = limit {
            items = limit(items)
        }
        
        var collectionViewItems = items
            .map {BECollectionViewItem(value: $0)}
        switch viewModel.currentState {
        case .loading:
            collectionViewItems += [
                BECollectionViewItem(placeholderIndex: UUID().uuidString),
                BECollectionViewItem(placeholderIndex: UUID().uuidString)
            ]
        case .loaded, .error, .initializing:
            break
        }
        return collectionViewItems
    }
    
    open func dataDidLoad() {
        
    }
    
    public func headerView() -> UICollectionReusableView? {
        collectionView?.sectionHeaderView(sectionIndex: index)
    }
    
    public func footerView() -> UICollectionReusableView? {
        collectionView?.sectionFooterView(sectionIndex: index)
    }
    
    // MARK: - CollectionView
    public var collectionViewLayout: UICollectionViewLayout? {
        collectionView?.collectionView.collectionViewLayout
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
