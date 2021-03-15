//
//  BECollectionViewItem.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

public struct BECollectionViewItem: Hashable {
    var placeholderIndex: Int?
    var value: AnyHashable?
    
    var isPlaceholder: Bool {placeholderIndex != nil}
}
