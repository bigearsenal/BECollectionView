//
//  BECollectionViewHeaderFooterViewLayout.swift
//  BECollectionView
//
//  Created by Chung Tran on 07/07/2021.
//

import Foundation
import UIKit

public struct BECollectionViewHeaderFooterViewLayout {
    public init(viewType: UICollectionReusableView.Type, widthDimension: NSCollectionLayoutDimension = .fractionalWidth(1), heightDimension: NSCollectionLayoutDimension, pinToVisibleBounds: Bool = false) {
        self.viewType = viewType
        self.widthDimension = widthDimension
        self.heightDimension = heightDimension
        self.pinToVisibleBounds = pinToVisibleBounds
    }
    
    public let viewType: UICollectionReusableView.Type
    public let widthDimension: NSCollectionLayoutDimension
    public let heightDimension: NSCollectionLayoutDimension
    public let pinToVisibleBounds: Bool
}
