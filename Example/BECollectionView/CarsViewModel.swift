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
        super.createRequest()
            .map { _ in
                [
                    Car(name: "Ferrari", numberOfWheels: 1),
                    Car(name: "Lada", numberOfWheels: 4)
                ]
            }
    }
}
