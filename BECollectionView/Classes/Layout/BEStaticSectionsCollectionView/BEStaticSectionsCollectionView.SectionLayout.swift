//
//  BEStaticSectionsCollectionView.SectionLayout.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

@available(*, deprecated, renamed: "BEStaticSectionsCollectionView.SectionLayout")
open class BECollectionViewSectionLayout {}

extension BEStaticSectionsCollectionView {
    public struct SectionLayout {
        // MARK: - Initializers
        public init(
            header: Header? = nil,
            footer: Footer? = nil,
            cellType: BECollectionViewCell.Type,
            emptyCellType: UICollectionViewCell.Type? = nil,
            interGroupSpacing: CGFloat? = nil,
            orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
            itemHeight: NSCollectionLayoutDimension = NSCollectionLayoutDimension.estimated(100),
            contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            horizontalInterItemSpacing: NSCollectionLayoutSpacing = NSCollectionLayoutSpacing.fixed(16),
            background: UICollectionReusableView.Type? = nil,
            customLayoutForGroupOnSmallScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)? = nil,
            customLayoutForGroupOnLargeScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)? = nil
        ) {
            self.header = header
            self.footer = footer
            self.cellType = cellType
            self.emptyCellType = emptyCellType
            self.interGroupSpacing = interGroupSpacing
            self.orthogonalScrollingBehavior = orthogonalScrollingBehavior
            self.itemHeight = itemHeight
            self.contentInsets = contentInsets
            self.horizontalInterItemSpacing = horizontalInterItemSpacing
            self.background = background
            self.customLayoutForGroupOnSmallScreen = customLayoutForGroupOnSmallScreen
            self.customLayoutForGroupOnLargeScreen = customLayoutForGroupOnLargeScreen
        }
        
        public struct Header {
            public init(identifier: String? = nil, viewClass: UICollectionReusableView.Type = UICollectionReusableView.self, heightDimension: NSCollectionLayoutDimension = .estimated(20), customLayout: NSCollectionLayoutBoundarySupplementaryItem? = nil) {
                self.identifier = identifier ?? String(describing: viewClass)
                self.viewClass = viewClass
                self.heightDimension = heightDimension
                self.customLayout = customLayout
            }
            public var identifier: String
            public var viewClass: UICollectionReusableView.Type = UICollectionReusableView.self
            public var heightDimension: NSCollectionLayoutDimension = .estimated(20)
            public var customLayout: NSCollectionLayoutBoundarySupplementaryItem? = nil
            public var layout: NSCollectionLayoutBoundarySupplementaryItem {
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
                return NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            }
        }
        
        public struct Footer {
            public init(identifier: String? = nil, viewClass: UICollectionReusableView.Type = UICollectionReusableView.self, heightDimension: NSCollectionLayoutDimension = .estimated(20), customLayout: NSCollectionLayoutBoundarySupplementaryItem? = nil) {
                self.identifier = identifier ?? String(describing: viewClass)
                self.viewClass = viewClass
                self.heightDimension = heightDimension
                self.customLayout = customLayout
            }
            
            public var identifier: String
            public var viewClass: UICollectionReusableView.Type = UICollectionReusableView.self
            public var heightDimension: NSCollectionLayoutDimension = .estimated(20)
            public var customLayout: NSCollectionLayoutBoundarySupplementaryItem? = nil
            public var layout: NSCollectionLayoutBoundarySupplementaryItem {
                if let layout = customLayout {return layout}
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
                return NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: size,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
            }
        }
        
        public var header: Header?
        public var footer: Footer?
        public var cellType: BECollectionViewCell.Type
        public var emptyCellType: UICollectionViewCell.Type?
        public var interGroupSpacing: CGFloat?
        public var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
        public var itemHeight = NSCollectionLayoutDimension.estimated(100)
        public var contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        public var horizontalInterItemSpacing = NSCollectionLayoutSpacing.fixed(16)
        public var background: UICollectionReusableView.Type?
        public var customLayoutForGroupOnSmallScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)?
        public var customLayoutForGroupOnLargeScreen: ((NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)?
        
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
}

extension Array where Element == BEStaticSectionsCollectionView.SectionLayout {
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
