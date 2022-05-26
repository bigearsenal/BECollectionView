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
        
        let firstViewController = StaticSectionsViewController(nibName: nil, bundle: nil)
        firstViewController.tabBarItem = UITabBarItem(title: "Static", image: nil, selectedImage: nil)
        
        
        let secondViewController = DynamicSectionsViewController(nibName: nil, bundle: nil)
        secondViewController.tabBarItem = UITabBarItem(title: "Dynamic", image: nil, selectedImage: nil)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [firstViewController, secondViewController]
        
//        tabBarController.selectedViewController = secondViewController
        
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.didMove(toParent: self)
    }
}
