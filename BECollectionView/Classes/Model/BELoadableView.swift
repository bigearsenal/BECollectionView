//
//  BELoadableView.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation

public protocol BELoadableViewType: UIView {
    func showLoading()
    func hideLoading()
}
