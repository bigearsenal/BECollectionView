//
//  ViewController.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView

class ViewController: UIViewController {
    lazy var collectionView: BECollectionView = {
        let section0 = CarsSection(viewModel: CarsViewModel())
        let section1 = FriendsSection(viewModel: FriendsViewModel())
        let collectionView = BECollectionView(sections: [section0, section1])
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.configureForAutoLayout()
        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
    }
}
