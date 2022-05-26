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
    
    let viewType: UICollectionReusableView.Type
    let widthDimension: NSCollectionLayoutDimension
    let heightDimension: NSCollectionLayoutDimension
    let pinToVisibleBounds: Bool
}
