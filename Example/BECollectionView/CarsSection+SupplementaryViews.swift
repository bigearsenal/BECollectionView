//
//  CarsSection+SupplementaryViews.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 16/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView

class CarsSectionHeaderView: BESectionHeaderView {
    override var padding: UIEdgeInsets {.init(top: 16, left: 16, bottom: 16, right: 16)}
    lazy var titleLabel = UILabel(forAutoLayout: ())
    override func commonInit() {
        super.commonInit()
        titleLabel.text = "Test title"
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFont(ofSize: 21)
        stackView.addArrangedSubview(titleLabel)
    }
}

class CarsSectionFooterView: BESectionFooterView {
    override var padding: UIEdgeInsets {.init(top: 10, left: 0, bottom: 10, right: 0)}
    lazy var colorView = UIView(forAutoLayout: ())
    override func commonInit() {
        super.commonInit()
        colorView.backgroundColor = .gray
        colorView.autoSetDimension(.height, toSize: 1)
        stackView.addArrangedSubview(colorView)
    }
}
