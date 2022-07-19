// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BECollectionView",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "BECollectionView_Core",
            targets: ["BECollectionView_Core"]
        ),
        .library(
            name: "BECollectionView",
            targets: ["BECollectionView"]
        ),
        .library(
            name: "BECollectionView_Combine",
            targets: ["BECollectionView_Combine"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.2.1")
    ],
    targets: [
        .target(
            name: "BECollectionView_Core"
        ),
        // BECollectionView+RxSwift
        .target(
            name: "BECollectionView",
            dependencies: [
                "BECollectionView_Core",
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift")
            ]),
        .testTarget(
            name: "BECollectionViewTests",
            dependencies: ["BECollectionView"]
        ),
        // BECollectionView+Combine
        .target(
            name: "BECollectionView_Combine",
            dependencies: [
                "BECollectionView_Core",
                "CombineCocoa"
            ]
        )
    ]
)
