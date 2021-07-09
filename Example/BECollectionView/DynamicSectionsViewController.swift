//
//  DynamicSectionsViewController.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 09/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BECollectionView

class DynamicSectionsViewController: UIViewController, BECollectionViewDelegate {
//    lazy var collectionView = BEDynamicSectionsCollectionView(
//        header: .init(
//            viewType: MyHeaderView.self,
//            heightDimension: .estimated(44)
//        ),
//        footer: .init(
//            viewType: MyFooterView.self,
//            heightDimension: .estimated(44)
//        )
//    )
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        collectionView.configureForAutoLayout()
//        view.addSubview(collectionView)
//        collectionView.autoPinEdgesToSuperviewEdges()
//        collectionView.delegate = self
//        
//        collectionView.refresh()
//        
//        let button = UIButton(forAutoLayout: ())
//        button.setTitle("change", for: .normal)
//        button.addTarget(self, action: #selector(buttonDidTouch), for: .touchUpInside)
//        button.setTitleColor(.blue, for: .normal)
//        
//        view.addSubview(button)
//        button.autoCenterInSuperview()
//    }
//    
//    func beCollectionView(collectionView: BECollectionViewBase, didSelect item: AnyHashable) {
//        switch item {
//        case let car as Car:
//            print(car.name)
//        case let friend as Friend:
//            print(friend.name)
//        default:
//            break
//        }
//    }
//    
//    var flow = false
//    @objc func buttonDidTouch() {
//        if !flow {
//            collectionView.collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true)
//        } else {
//            let config = collectionView.compositionalLayoutConfiguration()
//            let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//                nil
//            }, configuration: config)
//            collectionView.collectionView.setCollectionViewLayout(layout, animated: true)
//            let snapshot = NSDiffableDataSourceSnapshot<AnyHashable, BECollectionViewItem>()
//            collectionView.dataSource.apply(snapshot)
//        }
//        flow.toggle()
//    }
}
