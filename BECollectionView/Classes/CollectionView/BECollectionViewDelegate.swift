//
//  BECollectionViewDelegate.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

protocol BECollectionViewDelegate: class {
    func dataDidLoad()
    func itemDidSelect(_ item: AnyHashable)
}
