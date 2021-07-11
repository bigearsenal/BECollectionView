//
//  DynamicCollectionView.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 09/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView

class DynamicCollectionView: BEDynamicSectionsCollectionView {
    init() {
        super.init(
            header: .init(
                viewType: GlobalHeaderView.self,
                heightDimension: .estimated(53)
            ),
            viewModel: CarsViewModel(),
            mapDataToSections: { viewModel in
                let cars = viewModel.getData(type: Car.self)
                let dict = Dictionary(grouping: cars, by: {$0.numberOfWheels})
                return dict.keys.sorted()
                    .map {key in
                        SectionInfo(
                            userInfo: key,
                            items: dict[key]!
                        )
                    }
            },
            layout: .init(
                header: .init(
                    viewClass: CarsSectionHeaderView.self
                ),
                cellType: CarCell.self,
                emptyCellType: BECollectionViewBasicEmptyCell.self,
                interGroupSpacing: 2,
                itemHeight: .estimated(17),
                contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
                horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
            ),
            footer: .init(
                viewType: GlobalFooterView.self,
                heightDimension: .estimated(53)
            )
        )
    }
    
    override func configureSectionHeaderView(view: UICollectionReusableView?, sectionIndex: Int) {
        let view = view as? CarsSectionHeaderView
        guard sectionIndex < sections.count else {
            view?.titleLabel.text = "\(viewModel.currentState)"
            return
        }
        view?.titleLabel.text = "Number of wheels = \(sections[sectionIndex].userInfo)"
    }
}
