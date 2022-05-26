// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BECollectioniView",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BECollectionView",
            targets: ["BECollectionView"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/PureLayout/PureLayout", from: "3.1.9"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BECollectionView",
            dependencies: ["PureLayout", "RxSwift", .product(name: "RxCocoa", package: "RxSwift")]),
        .testTarget(
            name: "BECollectionViewTests",
            dependencies: ["BECollectionView"]),
    ]
)
