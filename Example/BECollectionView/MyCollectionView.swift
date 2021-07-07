//
//  MyCollectionView.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 07/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView

class MyHeaderView: BaseCollectionReusableView {
    lazy var titleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .center
        label.text = "Global header"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 44)
        return label
    }()
    override func commonInit() {
        super.commonInit()
        backgroundColor = .red
        stackView.addArrangedSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges()
    }
}

class MyCollectionView: BECollectionView {
    let headerIdentifier = "GlobalHeader"
    
    init() {
        let section0 = CarsSection(index: 0, viewModel: CarsViewModel())
        let section1 = FriendsSection(index: 1, viewModel: FriendsViewModel())
        super.init(sections: [section0, section1])
    }
    
    override func compositionalLayoutConfiguration() -> UICollectionViewCompositionalLayoutConfiguration {
        let config = super.compositionalLayoutConfiguration()
        let globalHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let globalHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: globalHeaderSize, elementKind: headerIdentifier, alignment: .top)
        globalHeader.pinToVisibleBounds = true
        config.interSectionSpacing = 20
        config.boundarySupplementaryItems = [globalHeader]
        return config
    }
}
