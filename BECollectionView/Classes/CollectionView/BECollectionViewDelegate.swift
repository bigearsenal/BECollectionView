//
//  BECollectionViewDelegate.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

@objc public protocol BECollectionViewDelegate: class {
    @objc optional func dataDidLoad()
    @objc optional func itemDidSelect(_ item: AnyHashable)
}
