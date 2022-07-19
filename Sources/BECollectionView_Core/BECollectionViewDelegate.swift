//
//  BECollectionViewDelegate.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

@objc public protocol BECollectionViewDelegate: AnyObject {
    @objc optional func beCollectionViewDataDidLoad(collectionView: BECollectionViewBase)
    @objc optional func beCollectionView(collectionView: BECollectionViewBase, didSelect item: AnyHashable)
}
