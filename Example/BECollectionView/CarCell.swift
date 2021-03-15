//
//  CarCell.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView

class CarCell: BECollectionViewCell {
    
    lazy var titleLabel = UILabel(forAutoLayout: ())
    lazy var descriptionLabel = UILabel(forAutoLayout: ())
    
    override func commonInit() {
        super.commonInit()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    override func setUp(with item: AnyHashable?) {
        guard let car = item as? Car else {
            titleLabel.text = "<placeholder>"
            descriptionLabel.text = "<placeholder>"
            return
        }
        titleLabel.text = car.name
        descriptionLabel.text = "\(car.numberOfWheels)"
    }
}
