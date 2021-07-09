//
//  BEDynamicSectionsCollectionView.swift
//  BECollectionView
//
//  Created by Chung Tran on 09/07/2021.
//

import Foundation

open class BEDynamicSectionsCollectionView: BECollectionViewBase {
    override func commonInit() {
        super.commonInit()
        let snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
        dataSource.apply(snapshot)
    }
}
