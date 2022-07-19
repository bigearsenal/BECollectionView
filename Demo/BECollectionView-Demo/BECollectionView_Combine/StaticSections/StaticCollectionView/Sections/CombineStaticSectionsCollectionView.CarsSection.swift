//
//  CombineStaticSectionsCollectionView.CarsSection.swift
//  BECollectionView-Demo
//
//  Created by Chung Tran on 19/07/2022.
//

import Foundation
import UIKit
import BECollectionView_Core
import BECollectionView_Combine

extension CombineStaticSectionsCollectionView {
    class CarsSection: BEStaticSectionsCollectionView.Section {
        init(index: Int, viewModel: BECollectionViewModelType) {
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
