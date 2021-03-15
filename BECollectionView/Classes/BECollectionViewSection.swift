//
//  BECollectionViewSection.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

struct BECollectionViewSection {
    struct Header {
        var viewClass: BESectionHeaderView.Type = BESectionHeaderView.self
        var title: String
        var titleFont: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        var heightDimension: NSCollectionLayoutDimension = .estimated(10)
        var layout: NSCollectionLayoutBoundarySupplementaryItem {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
            return NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionElementKindSectionHeader,
                alignment: .top
            )
        }
    }
    
    struct Footer {
        var viewClass: BESectionFooterView.Type = BESectionFooterView.self
        var layout: NSCollectionLayoutBoundarySupplementaryItem = {
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(20))
            return NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: size,
                elementKind: UICollectionElementKindSectionFooter,
                alignment: .bottom
            )
        }()
    }
    
    var header: Header?
    var footer: Footer?
    var cellType: BaseCollectionViewCell.Type
    var interGroupSpacing: CGFloat?
    var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
    var itemHeight = NSCollectionLayoutDimension.estimated(100)
    var contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    var horizontalInterItemSpacing = NSCollectionLayoutSpacing.fixed(16)
    var background: BESectionBackgroundView.Type?
    var customLayoutForGroupOnSmallScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)?
    var customLayoutForGroupOnLargeScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)?
    
    func registerCellAndSupplementaryViews(in collectionView: UICollectionView) {
        // register cell
        collectionView.register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
        
        // register header
        if let header = header {
            collectionView.register(header.viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: header.viewClass))
        }
        
        // register footer
        if let footer = footer {
            collectionView.register(footer.viewClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(describing: footer.viewClass))
        }
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

extension Array where Element == BECollectionViewSection {
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
