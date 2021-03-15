//
//  ViewController.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView

class ViewController: UIViewController {
    lazy var collectionView: BECollectionView = {
        let section0 = BECollectionViewSection(
            layout: BECollectionViewSectionLayout(
//                header: BECollectionViewSection.Header(viewClass: ActiveWalletsSectionHeaderView.self, title: ""),
                cellType: CarCell.self,
                interGroupSpacing: 30,
                itemHeight: .estimated(17),
                horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
            ),
            viewModel: CarsViewModel()
        )
        let section1 = BECollectionViewSection(
            layout: BECollectionViewSectionLayout(
                cellType: FriendCell.self,
                interGroupSpacing: 16,
                contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
                horizontalInterItemSpacing: .fixed(16),
                customLayoutForGroupOnSmallScreen: {_ in
                    self.groupLayoutForFriendSection()
                },
                customLayoutForGroupOnLargeScreen: {_ in
                    self.groupLayoutForFriendSection()
                }),
            viewModel: FriendsViewModel()
        )
        let collectionView = BECollectionView(sections: [
            section0,
            section1
        ])
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.configureForAutoLayout()
        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
    }
    
    private func groupLayoutForFriendSection() -> NSCollectionLayoutGroup {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(80), heightDimension: .estimated(73))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        return group
    }
}
