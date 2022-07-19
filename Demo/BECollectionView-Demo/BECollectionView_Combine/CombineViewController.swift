//
//  RxSwiftViewController.swift
//  BECollectionView-Demo
//
//  Created by Chung Tran on 18/07/2022.
//

import Foundation
import UIKit
import BECollectionView_Core

class CombineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let staticButton = UIButton()
        staticButton.setTitle("StaticSections", for: .normal)
        staticButton.setTitleColor(.blue, for: .normal)
        staticButton.addTarget(self, action: #selector(staticButtonDidTouch), for: .touchUpInside)
        
        let dynamicButton = UIButton()
        dynamicButton.setTitle("DynamicSections", for: .normal)
        dynamicButton.setTitleColor(.blue, for: .normal)
        dynamicButton.addTarget(self, action: #selector(dynamicButtonDidTouch), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [staticButton, dynamicButton])
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        stackView.autoCenterInSuperview()
    }
    
    @objc private func staticButtonDidTouch() {
        let vc = CombineStaticSectionsViewController()
        show(vc, sender: nil)
    }
    
    @objc private func dynamicButtonDidTouch() {
        let vc = RxSwiftDynamicSectionsViewController()
        show(vc, sender: nil)
    }
}
