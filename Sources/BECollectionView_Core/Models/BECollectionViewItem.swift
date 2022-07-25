//
//  BECollectionViewItem.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

public struct BECollectionViewItem: Hashable {
    public init(value: AnyHashable? = nil, placeholderIndex: String? = nil, emptyCellIndex: String? = nil) {
        self.value = value
        self.placeholderIndex = placeholderIndex
        self.emptyCellIndex = emptyCellIndex
    }
    
    public var value: AnyHashable?
    var placeholderIndex: String?
    var emptyCellIndex: String?
    
    public var isPlaceholder: Bool {placeholderIndex != nil}
    var isEmptyCell: Bool {emptyCellIndex != nil}
}
