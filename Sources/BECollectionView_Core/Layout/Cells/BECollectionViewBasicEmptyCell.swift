//
//  BECollectionViewBasicEmptyCell.swift
//  BECollectionView
//
//  Created by Chung Tran on 12/04/2021.
//

import Foundation
import UIKit

public class BECollectionViewBasicEmptyCell: UICollectionViewCell {
    public lazy var label: UILabel = {
        let label = UILabel()
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
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
    }
}
