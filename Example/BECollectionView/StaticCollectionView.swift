//
//  MyCollectionView.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 07/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView

class StaticCollectionView: BEStaticSectionsCollectionView {
    let headerIdentifier = "GlobalHeader"
    
    init() {
        let section0 = CarsSection(index: 0, viewModel: CarsViewModel())
        let section1 = FriendsSection(index: 1, viewModel: FriendsViewModel())
        super.init(
            header: .init(
                viewType: GlobalHeaderView.self,
                heightDimension: .estimated(53)
            ),
            sections: [section0, section1],
            footer: .init(
                viewType: GlobalFooterView.self,
                heightDimension: .estimated(53)
            )
        )
    }
    
    override func configureHeaderView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        let headerView = super.configureHeaderView(kind: kind, indexPath: indexPath) as? GlobalHeaderView
        headerView?.viewModel = sections.first?.viewModel as? CarsViewModel
        return headerView
    }
    
    override func configureFooterView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        let footerView = super.configureFooterView(kind: kind, indexPath: indexPath) as? GlobalFooterView
        footerView?.viewModel = sections.last?.viewModel as? FriendsViewModel
        return footerView
    }
}
