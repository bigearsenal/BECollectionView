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
                itemHeight: .absolute(45),
                horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
            ),
            viewModel: CarsViewModel()
        )
        let section1 = BECollectionViewSection(
            layout: BECollectionViewSectionLayout(
//                header: CollectionViewSection.Header(
//                    viewClass: HiddenWalletsSectionHeaderView.self, title: L10n.hiddenWallets
//                ),
//                footer: CollectionViewSection.Footer(viewClass: WalletsSectionFooterView.self),
                cellType: FriendCell.self,
                interGroupSpacing: 30,
                itemHeight: .absolute(45),
                horizontalInterItemSpacing: NSCollectionLayoutSpacing.fixed(16)
            ),
            viewModel: FriendsViewModel()
        )
        let collectionView = BECollectionView(sections: [
            section0
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
}
