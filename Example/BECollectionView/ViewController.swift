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
        collectionView.delegate = self
    }
    
    func beCollectionViewDataDidLoad(collectionView: BECollectionView) {
        let section0Header = collectionView.sectionHeaderView(sectionIndex: 0) as? CarsSectionHeaderView
        let oldText = section0Header?.titleLabel.text
        let newText = "Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text."
        
        if oldText != newText {
            section0Header?.titleLabel.text = "Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text.Very long text."
            let context = UICollectionViewLayoutInvalidationContext()
            context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: [IndexPath(row: 0, section: 0)])
            collectionView.relayout(context)
        }
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
