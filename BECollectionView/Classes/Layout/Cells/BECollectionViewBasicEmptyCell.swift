//
//  BECollectionViewBasicEmptyCell.swift
//  BECollectionView
//
//  Created by Chung Tran on 12/04/2021.
//

import Foundation

public class BECollectionViewBasicEmptyCell: UICollectionViewCell {
    public lazy var label: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.text = NSLocalizedString("Not found", comment: "")
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func commonInit() {
        contentView.addSubview(label)
        label.autoPinEdgesToSuperviewEdges(with: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
}
