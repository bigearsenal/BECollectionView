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
    
    func registerCellAndSupplementaryViews() {
        // register cell
        collectionView?.collectionView.register(layout.cellType, forCellWithReuseIdentifier: String(describing: layout.cellType))
        collectionView?.collectionView
            .register(layout.emptyCellType, forCellWithReuseIdentifier: emptyCellIdentifier)
        
        // register header
        if let header = layout.header?.viewClass {
            collectionView?.collectionView.register(header, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        }
        
        
        // register footer
        if let footer = layout.footer?.viewClass {
            collectionView?.collectionView.register(footer, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        }
        
    }
    
    open func mapDataToCollectionViewItems() -> [BECollectionViewItem]
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
        case .loading, .initializing:
            collectionViewItems += [
                BECollectionViewItem(placeholderIndex: UUID().uuidString),
                BECollectionViewItem(placeholderIndex: UUID().uuidString)
            ]
        case .loaded:
            if collectionViewItems.isEmpty, layout.emptyCellType != nil {
                collectionViewItems = [BECollectionViewItem(emptyCellIndex: UUID().uuidString)]
            }
        case .error:
            break
        }
        return collectionViewItems
    }
    
    func configureSupplementaryView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            return configureHeader(indexPath: indexPath)
        }
        if kind == UICollectionView.elementKindSectionFooter {
            return configureFooter(indexPath: indexPath)
        }
        return nil
    }
    
    open func configureHeader(indexPath: IndexPath) -> UICollectionReusableView? {
        let view = collectionView?.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerIdentifier,
            for: indexPath)
        return view
    }
    
    open func configureFooter(indexPath: IndexPath) -> UICollectionReusableView? {
        let view = collectionView?.collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: footerIdentifier,
            for: indexPath)
        
        return view
    }
    
    open func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell {
        
        if !item.isEmptyCell,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: layout.cellType), for: indexPath) as? BECollectionViewCell {
            cell.setUp(with: item.value)
            
            if item.isPlaceholder {
                cell.hideLoading()
                cell.showLoading()
            } else {
                cell.hideLoading()
            }
            
            return cell
        }
        
        if item.isEmptyCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellIdentifier, for: indexPath)
        }
        
        return UICollectionViewCell()
    }
    
    open func reload() {
        viewModel.reload()
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
    
    // MARK: - Helper
    private var headerIdentifier: String {
        "Header#\(index)"
    }
    
    private var footerIdentifier: String {
        "Footer#\(index)"
    }
    
    private var emptyCellIdentifier: String {
        "EmptyCell#\(index)"
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
