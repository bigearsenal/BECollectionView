//
//  ViewController.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 09/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstViewController = RxSwiftViewController(nibName: nil, bundle: nil)
        firstViewController.tabBarItem = UITabBarItem(title: "RxSwift", image: .init(named: "RxSwift"), selectedImage: nil)
        
        
        let secondViewController = CombineViewController(nibName: nil, bundle: nil)
        secondViewController.tabBarItem = UITabBarItem(title: "Combine", image: .init(named: "Combine"), selectedImage: nil)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: firstViewController),
            secondViewController
        ]
        
//        tabBarController.selectedViewController = secondViewController
        
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.didMove(toParent: self)
    }
}
