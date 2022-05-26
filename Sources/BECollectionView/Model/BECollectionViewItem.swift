//
//  BECollectionViewItem.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

public struct BECollectionViewItem: Hashable {
    public var value: AnyHashable?
    var placeholderIndex: String?
    var emptyCellIndex: String?
    
    var isPlaceholder: Bool {placeholderIndex != nil}
    var isEmptyCell: Bool {emptyCellIndex != nil}
}
