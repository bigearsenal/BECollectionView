//
//  BaseCell.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 23/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView
import ListPlaceholder

class BaseCell: UICollectionViewCell, BECollectionViewCell {
    var padding: UIEdgeInsets {.zero}
    public lazy var stackView = UIStackView(forAutoLayout: ())
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable,
    message: "Loading this view from a nib is unsupported in favor of initializer dependency injection."
    )
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func commonInit() {
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .zero)
    }
    
    open func setUp(with item: AnyHashable?) {}
    
    func hideLoading() {
        stackView.hideLoader()
    }
    
    func showLoading() {
        stackView.showLoader()
    }
}
