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
        await Task {
            // generate cars
            var cars = [Car]()
            for i in 0..<10 {
                cars.append(.init(name: "Car#\(i)", numberOfWheels: Int.random(in: 0..<4)))
            }

            return Array(
                cars.prefix(Bool.random() ? cars.count: 0)
            )
        }.value
    }
}
