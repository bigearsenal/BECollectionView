//
//  CombineFriendsViewModel.swift
//  BECollectionView-Demo
//
//  Created by Chung Tran on 18/07/2022.
//

import Foundation
import Combine
import BECollectionView_Combine

class CombineFriendsViewModel: BECollectionViewModel<Friend> {
    override func createRequest() async throws -> [Friend] {
        await Task {
            Array(
                [
                    Friend(name: "Ty", numberOfLegs: 1),
                    Friend(name: "Phi", numberOfLegs: 2),
                    Friend(name: "Phid", numberOfLegs: 3)
                ]
                    .prefix(Bool.random() ? 0: 3)
            )
        }.value
    }
}
