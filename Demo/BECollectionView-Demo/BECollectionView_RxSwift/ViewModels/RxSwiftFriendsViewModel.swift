//
//  FriendsViewModel.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView
import RxSwift

class RxSwiftFriendsViewModel: BERxListViewModel<Friend> {
    override func createRequest() -> Single<[Friend]> {
        Single<[Friend]>.just(data).delay(.seconds(Int.random(in: 2..<6)), scheduler: MainScheduler.instance)
            .map { _ in
                Array(
                    [
                        Friend(name: "Ty", numberOfLegs: 1),
                        Friend(name: "Phi", numberOfLegs: 2),
                        Friend(name: "Phid", numberOfLegs: 3)
                    ].prefix(Bool.random() ? 0: 3)
                )
            }
    }
}
