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
            header: BECollectionViewSectionLayout.Header(viewClass: CarsSectionHeaderView.self),
            footer: BECollectionViewSectionLayout.Footer(viewClass: CarsSectionFooterView.self),
            cellType: CarCell.self,
            interGroupSpacing: 16,
            itemHeight: .estimated(17),
            contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
            horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
        )
        super.init(layout: layout, viewModel: viewModel)
    }
}
