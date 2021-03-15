//
//  CarsSection.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 16/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView

class CarsSection: BECollectionViewSection {
    init(viewModel: BEListViewModelType) {
        let layout = BECollectionViewSectionLayout(
//                header: BECollectionViewSection.Header(viewClass: ActiveWalletsSectionHeaderView.self, title: ""),
            cellType: CarCell.self,
            interGroupSpacing: 30,
            itemHeight: .estimated(17),
            horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
        )
        super.init(layout: layout, viewModel: viewModel)
    }
}
