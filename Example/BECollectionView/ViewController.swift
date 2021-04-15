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

class MyCollectionView: BECollectionView {
    init() {
        super.init(viewModels: [
            CarsViewModel(),
            FriendsViewModel()
        ])
    }
    
    override func mapDataToSections() -> [BECollectionViewSection] {
        Bool.random() ?
        [
            CarsSection(index: 0, viewModel: viewModels[0]),
            FriendsSection(index: 1, viewModel: viewModels[1])
        ] :
            [
                FriendsSection(index: 0, viewModel: viewModels[1]),
                CarsSection(index: 1, viewModel: viewModels[0])
            ]
    }
}

class ViewController: UIViewController, BECollectionViewDelegate {
    lazy var collectionView = MyCollectionView()
    
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
