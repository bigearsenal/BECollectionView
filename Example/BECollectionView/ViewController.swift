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

class ViewController: UIViewController, BECollectionViewDelegate {
    lazy var collectionView: BECollectionView = {
        let section0 = CarsSection(index: 0, viewModel: CarsViewModel())
        let section1 = FriendsSection(index: 1, viewModel: FriendsViewModel())
        let collectionView = BECollectionView(sections: [section0, section1])
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.configureForAutoLayout()
        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
        collectionView.delegate = self
        
        collectionView.refresh()
    }
    
    func beCollectionView(collectionView: BECollectionView, didSelect item: AnyHashable) {
        switch item {
        case let car as Car:
            print(car.name)
        case let friend as Friend:
            print(friend.name)
        default:
            break
        }
    }
}
