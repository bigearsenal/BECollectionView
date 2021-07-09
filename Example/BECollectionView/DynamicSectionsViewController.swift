//
//  DynamicSectionsViewController.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 09/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView

class DynamicSectionsViewController: UIViewController, BECollectionViewDelegate {
    lazy var collectionView = BEDynamicSectionsCollectionView(
        header: .init(
            viewType: MyHeaderView.self,
            heightDimension: .estimated(44)
        ),
        viewModel: CarsViewModel(),
        mapDataToSections: { viewModel in
            let cars = viewModel.getData(type: Car.self)
            let dict = Dictionary(grouping: cars, by: {$0.numberOfWheels})
            return dict.map { key, value in
                BEDynamicSectionsCollectionView.SectionInfo(
                    userInfo: key,
                    layout: .init(
                        index: 0,
                        layout: .init(
//                            header: <#T##BECollectionViewSectionHeaderLayout?#>,
//                            footer: <#T##BECollectionViewSectionFooterLayout?#>,
                            cellType: CarCell.self,
                            emptyCellType: BECollectionViewBasicEmptyCell.self,
                            interGroupSpacing: 16,
                            itemHeight: .estimated(17),
                            contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
                            horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
                        )
                    ),
                    items: value
                )
            }
        },
        footer: .init(
            viewType: MyFooterView.self,
            heightDimension: .estimated(44)
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.configureForAutoLayout()
        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
        collectionView.delegate = self
        
        collectionView.refresh()
    }
    
    func beCollectionView(collectionView: BECollectionViewBase, didSelect item: AnyHashable) {
        switch item {
        case let car as Car:
            print(car.name)
        case let friend as Friend:
            print(friend.name)
        default:
            break
        }
    }
}
