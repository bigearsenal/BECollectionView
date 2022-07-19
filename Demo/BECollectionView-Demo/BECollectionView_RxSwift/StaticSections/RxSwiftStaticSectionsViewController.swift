//
//  ViewController.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView_Core

class RxSwiftStaticSectionsViewController: UIViewController, BECollectionViewDelegate {
    lazy var collectionView = RxSwiftStaticCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CollectionView with static sections"
        view.backgroundColor = .white
        collectionView.configureForAutoLayout()
        view.addSubview(collectionView)
        collectionView.autoPinEdgesToSuperviewEdges()
        collectionView.delegate = self
        
        collectionView.refresh()
    }
    
    func beCollectionView(collectionView: BECollectionViewBase, didSelect item: AnyHashable) {
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
