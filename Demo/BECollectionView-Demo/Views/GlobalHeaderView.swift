//
//  GlobalHeaderView.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 07/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class GlobalHeaderView: BaseCollectionReusableView {
    var disposable: Disposable?
    
    var rxViewModel: RxSwiftCarsViewModel? {
        didSet {
            guard let viewModel = rxViewModel else {return}
            disposable?.dispose()
            disposable = viewModel.dataObservable
                .map {$0?.count ?? 0}
                .map {"\($0) car(s)"}
                .asDriver(onErrorJustReturn: "")
                .drive(titleLabel.rx.text)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.textAlignment = .center
        label.text = "Global header"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 44)
        return label
    }()
    override func commonInit() {
        super.commonInit()
        backgroundColor = .red
        stackView.addArrangedSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges()
    }
}
