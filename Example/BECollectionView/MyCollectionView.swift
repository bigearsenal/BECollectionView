//
//  MyCollectionView.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 07/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView
import RxSwift

class MyHeaderView: BaseCollectionReusableView {
    var disposable: Disposable?
    
    var viewModel: CarsViewModel? {
        didSet {
            guard let viewModel = viewModel else {return}
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

class MyCollectionView: BECollectionView {
    let headerIdentifier = "GlobalHeader"
    
    init() {
        let section0 = CarsSection(index: 0, viewModel: CarsViewModel())
        let section1 = FriendsSection(index: 1, viewModel: FriendsViewModel())
        super.init(
            header: .init(
                viewType: MyHeaderView.self,
                heightDimension: .estimated(44)
            ),
            sections: [section0, section1]
        )
    }
    
    override func configureHeaderView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        let headerView = super.configureHeaderView(kind: kind, indexPath: indexPath) as? MyHeaderView
        headerView?.viewModel = sections.first?.viewModel as? CarsViewModel
        return headerView
    }
}
