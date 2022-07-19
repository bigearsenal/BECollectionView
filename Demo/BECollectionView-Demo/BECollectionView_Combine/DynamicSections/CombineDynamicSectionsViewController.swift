//
//  CombineDynamicSectionsViewController.swift
//  BECollectionView-Demo
//
//  Created by Chung Tran on 19/07/2022.
//

import Foundation
import UIKit
import PureLayout
import BECollectionView_Combine

class CombineDynamicSectionsViewController: UIViewController, BECollectionViewDelegate {
    lazy var collectionView = CombineDynamicCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CollectionView with dynamic sections"
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
