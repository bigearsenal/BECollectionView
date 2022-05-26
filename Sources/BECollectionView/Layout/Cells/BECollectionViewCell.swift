//
//  BECollectionViewCell.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import UIKit

public protocol BECollectionViewCell: UICollectionViewCell {
    func setUp(with item: AnyHashable?)
    func hideLoading()
    func showLoading()
}
