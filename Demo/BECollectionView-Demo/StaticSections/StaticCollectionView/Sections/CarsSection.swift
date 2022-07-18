//
//  CarsSection.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 16/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView
import BECollectionView_Core
import UIKit

extension StaticCollectionView {
    class CarsSection: BEStaticSectionsCollectionView.Section {
        init(index: Int, viewModel: BEListViewModelType) {
            super.init(
                index: index,
                layout: .init(
                    header: .init(viewClass: CarsSectionHeaderView.self),
                    footer: .init(viewClass: CarsSectionFooterView.self),
                    cellType: CarCell.self,
                    emptyCellType: BECollectionViewBasicEmptyCell.self,
                    interGroupSpacing: 16,
                    itemHeight: .estimated(17),
                    contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
                    horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
                ),
                viewModel: viewModel
            )
        }
        
        override func dataDidLoad() {
            super.dataDidLoad()
            let section0Header = collectionView?.sectionHeaderView(sectionIndex: 0) as? CarsSectionHeaderView
            var newText = ""
            let text1 = "Test title"
            let text2 = "Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text."
            
            if text1 == section0Header?.titleLabel.text {
                newText = text2
            } else {
                newText = text1
            }
            
            section0Header?.titleLabel.text = newText
        }
    }
}
