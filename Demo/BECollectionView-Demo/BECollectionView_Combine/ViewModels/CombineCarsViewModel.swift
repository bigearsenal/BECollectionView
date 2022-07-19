//
//  CombineCarsViewModel.swift
//  BECollectionView-Demo
//
//  Created by Chung Tran on 18/07/2022.
//

import Foundation
import Combine
import BECollectionView_Combine

class CombineCarsViewModel: BECollectionViewModel<Car> {
    override func createRequest() async throws -> [Car] {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate loading
        try Task.checkCancellation()
        return (0...Int.random(in: 1..<9)).map {.init(name: "Car#\($0)", numberOfWheels: Int.random(in: 1..<4))}
    }
}
