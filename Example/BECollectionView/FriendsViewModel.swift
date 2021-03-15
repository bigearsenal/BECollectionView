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

class FriendsViewModel: BEListViewModel<Friend> {
    override func createRequest() -> Single<[Friend]> {
        super.createRequest()
            .map { _ in
                [
                    Friend(name: "Ty", numberOfLegs: 1),
                    Friend(name: "Phi", numberOfLegs: 2),
                    Friend(name: "Phid", numberOfLegs: 3)
                ]
            }
    }
}
