//
//  CarsViewModel.swift
//  BECollectionView_Example
//
//  Created by Chung Tran on 15/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import BECollectionView
import RxSwift

class CarsViewModel: BEListViewModel<Car> {
    override func createRequest() -> Single<[Car]> {
        Single<[Car]>.just(data).delay(.seconds(Int.random(in: 2..<5)), scheduler: MainScheduler.instance)
            .map { _ in
                // generate cars
                var cars = [Car]()
                for i in 0..<10 {
                    cars.append(.init(name: "Car#\(i)", numberOfWheels: Int.random(in: 0..<4)))
                }
                
                return Array(
                    cars.prefix(Bool.random() ? cars.count: 0)
                )
            }
    }
}
