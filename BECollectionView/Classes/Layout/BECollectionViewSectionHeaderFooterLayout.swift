//
//  BECollectionViewSectionHeaderFooterLayout.swift
//  BECollectionView
//
//  Created by Chung Tran on 09/07/2021.
//

import Foundation

public struct BECollectionViewSectionHeaderLayout {
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

public struct BECollectionViewSectionFooterLayout {
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
