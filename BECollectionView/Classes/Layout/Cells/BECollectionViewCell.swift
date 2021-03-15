//
//  BECollectionViewCell.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

open class BECollectionViewCell: UICollectionViewCell {
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
        stackView.autoPinEdgesToSuperviewEdges()
    }
    open func setUp(with item: AnyHashable?) {}
}
