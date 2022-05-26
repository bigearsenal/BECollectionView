//
//  FriendCell.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView
import UIKit

class FriendCell: BaseCell {
    override var padding: UIEdgeInsets {.init(top: 0, left: 0, bottom: 16, right: 0)}
    lazy var imageView = UIImageView()
    lazy var nameLabel = UILabel()
    
    override func commonInit() {
        super.commonInit()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        imageView.autoSetDimensions(to: CGSize(width: 50, height: 50))
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(nameLabel)
    }
    
    override func setUp(with item: AnyHashable?) {
        guard let friend = item as? Friend else {
            imageView.backgroundColor = .orange
            nameLabel.text = "<placeholder>"
            return
        }
        imageView.backgroundColor = .orange
        nameLabel.text = friend.name
    }
}
