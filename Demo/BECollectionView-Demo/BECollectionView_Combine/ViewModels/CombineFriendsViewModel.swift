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
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate loading
        try Task.checkCancellation()
        let result = [
            Friend(name: "Ty", numberOfLegs: 1),
            Friend(name: "Phi", numberOfLegs: 2),
            Friend(name: "Tai", numberOfLegs: 3)
        ]
        return Array(result.prefix(Int.random(in: 0..<result.count+1)))
    }
}
