//
//  BEStaticSectionsCollectionView.SectionLayout.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import UIKit

public struct BECollectionViewSectionLayout {
    // MARK: - Initializers
    public init(
        header: BECollectionViewSectionHeaderLayout? = nil,
        footer: BECollectionViewSectionFooterLayout? = nil,
        cellType: BECollectionViewCell.Type,
        emptyCellType: UICollectionViewCell.Type? = nil,
        numberOfLoadingCells: Int = 2,
        interGroupSpacing: CGFloat? = nil,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        itemHeight: NSCollectionLayoutDimension = NSCollectionLayoutDimension.estimated(100),
        contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        sectionInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        horizontalInterItemSpacing: NSCollectionLayoutSpacing = NSCollectionLayoutSpacing.fixed(16),
        background: UICollectionReusableView.Type? = nil,
        customLayoutForGroupOnSmallScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)? = nil,
        customLayoutForGroupOnLargeScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)? = nil
    ) {
        self.header = header
        self.footer = footer
        self.cellType = cellType
        self.emptyCellType = emptyCellType
        self.numberOfLoadingCells = numberOfLoadingCells
        self.interGroupSpacing = interGroupSpacing
        self.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        self.itemHeight = itemHeight
        self.contentInsets = contentInsets
        self.sectionInsets = sectionInsets
        self.horizontalInterItemSpacing = horizontalInterItemSpacing
        self.background = background
        self.customLayoutForGroupOnSmallScreen = customLayoutForGroupOnSmallScreen
        self.customLayoutForGroupOnLargeScreen = customLayoutForGroupOnLargeScreen
    }
    
    public var header: BECollectionViewSectionHeaderLayout?
    public var footer: BECollectionViewSectionFooterLayout?
    public var cellType: BECollectionViewCell.Type
    public var emptyCellType: UICollectionViewCell.Type?
    public let numberOfLoadingCells: Int
    public var interGroupSpacing: CGFloat?
    public var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
    public var itemHeight = NSCollectionLayoutDimension.estimated(100)
    public var contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    public var sectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    public var horizontalInterItemSpacing = NSCollectionLayoutSpacing.fixed(16)
    public var background: UICollectionReusableView.Type?
    public var customLayoutForGroupOnSmallScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)?
    public var customLayoutForGroupOnLargeScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)?
    
    func registerCellsAndSupplementaryViews(in collectionView: UICollectionView, emptyCellIdentifier: String? = nil, headerIdentifier: String? = nil, footerIdentifier: String? = nil) {
        // register cell
        collectionView.register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
        
        let emptyCellIdentifier = emptyCellIdentifier ?? String(describing: emptyCellType)
        collectionView
            .register(emptyCellType, forCellWithReuseIdentifier: emptyCellIdentifier)
        
        // register header
        if let header = header?.viewClass {
            let headerIdentifier = headerIdentifier ?? String(describing: header)
            collectionView.register(header, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        }
        
        
        // register footer
        if let footer = footer?.viewClass {
            let footerIdentifier = footerIdentifier ?? String(describing: footer)
            collectionView.register(footer, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        }
    }
    
    func configureSupplementaryView(in collectionView: UICollectionView, kind: String, indexPath: IndexPath, headerIdentifier: String? = nil, footerIdentifier: String? = nil) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            return configureHeader(in: collectionView, indexPath: indexPath, headerIdentifier: headerIdentifier)
        }
        if kind == UICollectionView.elementKindSectionFooter {
            return configureFooter(in: collectionView, indexPath: indexPath, footerIdentifier: footerIdentifier)
        }
        return nil
    }
    
    func configureHeader(in collectionView: UICollectionView, indexPath: IndexPath, headerIdentifier: String? = nil) -> UICollectionReusableView? {
        let headerIdentifier = headerIdentifier ?? String(describing: header!.viewClass)
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerIdentifier,
            for: indexPath)
        return view
    }
    
    func configureFooter(in collectionView: UICollectionView, indexPath: IndexPath, footerIdentifier: String? = nil) -> UICollectionReusableView? {
        let footerIdentifier = footerIdentifier ?? String(describing: footer!.viewClass)
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: footerIdentifier,
            for: indexPath)
        
        return view
    }
    
    func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem, emptyCellIdentifier: String? = nil) -> UICollectionViewCell {
        
        if !item.isEmptyCell,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellType), for: indexPath) as? BECollectionViewCell {
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
            let emptyCellIdentifier = emptyCellIdentifier ?? String(describing: emptyCellType)
            return collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellIdentifier, for: indexPath)
        }
        
        return UICollectionViewCell()
    }
    
    func layout(environment env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let group: NSCollectionLayoutGroup
        // 1 columns
        if env.container.contentSize.width < 536 {
            group = createLayoutForGroupOnSmallScreen(environment: env)
        // 2 columns
        } else {
            group = createLayoutForGroupOnLargeScreen(environment: env)
        }
        
        group.contentInsets = contentInsets
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets
        
        // supplementary items
        var supplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem]()
        
        if let header = header {
            supplementaryItems.append(header.layout)
        }
        
        if let footer = footer {
            supplementaryItems.append(footer.layout)
        }
        
        if !supplementaryItems.isEmpty {
            section.boundarySupplementaryItems = supplementaryItems
        }
        
        // decoration items
        var decorationItems = [NSCollectionLayoutDecorationItem]()
        
        if let background = background {
            decorationItems.append(NSCollectionLayoutDecorationItem.background(
                    elementKind: String(describing: background)))
        }
        
        if !decorationItems.isEmpty {
            section.decorationItems = decorationItems
        }
        
        if let interGroupSpacing = interGroupSpacing {
            section.interGroupSpacing = interGroupSpacing
        }
        
        if let orthogonalScrollingBehavior = orthogonalScrollingBehavior {
            section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        }
        
        return section
    }
    
    func createLayoutForGroupOnSmallScreen(environment env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        if let customLayout = customLayoutForGroupOnSmallScreen {
            return customLayout(env)
        }
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: itemHeight)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(env.container.contentSize.width), heightDimension: .estimated(200))
        
        return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    }
    
    func createLayoutForGroupOnLargeScreen(environment env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        if let customLayout = customLayoutForGroupOnLargeScreen {
            return customLayout(env)
        }
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: itemHeight)
        
        let leadingItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let trailingItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute((env.container.contentSize.width - horizontalInterItemSpacing.spacing - contentInsets.leading - contentInsets.trailing)/2), heightDimension: itemSize.heightDimension)
        
        let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [leadingItem])
        
        let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [trailingItem])
        
        let combinedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: combinedGroupSize, subitems: [leadingGroup, trailingGroup])
        group.interItemSpacing = horizontalInterItemSpacing
        return group
    }
}

extension Array where Element == BECollectionViewSectionLayout {
    func createLayout(interSectionSpacing: CGFloat? = nil) -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        if let interSectionSpacing = interSectionSpacing {
            config.interSectionSpacing = interSectionSpacing
        }
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self.createLayoutForSection(sectionIndex, environment: env)
        }, configuration: config)
        
        for section in self where section.background != nil {
            layout.register(section.background.self, forDecorationViewOfKind: String(describing: section.background!))
        }
        
        return layout
    }
    
    func createLayoutForSection(_ sectionIndex: Int, environment env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let section = self[sectionIndex]
        return section.layout(environment: env)
    }
}
