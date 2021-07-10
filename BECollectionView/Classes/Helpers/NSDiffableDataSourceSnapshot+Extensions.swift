//
//  NSDiffableDataSourceSnapshot+Extensions.swift
//  BECollectionView
//
//  Created by Chung Tran on 10/07/2021.
//

import Foundation

public extension NSDiffableDataSourceSnapshot where SectionIdentifierType: Hashable, ItemIdentifierType == BECollectionViewItem
{
    func isSectionEmpty(sectionIdentifier: SectionIdentifierType) -> Bool {
        let itemsCount = numberOfItems(inSection: sectionIdentifier)
        if itemsCount == 1,
           let firstItem = itemIdentifiers(inSection: sectionIdentifier)
            .first,
           firstItem.isEmptyCell
        {
            return true
        }
        return itemsCount == 0
    }
}
