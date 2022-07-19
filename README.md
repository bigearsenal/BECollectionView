# BECollectionView

[![CI Status](https://img.shields.io/travis/bigearsenal/BECollectionView.svg?style=flat)](https://travis-ci.org/bigearsenal/BECollectionView)
[![Version](https://img.shields.io/cocoapods/v/BECollectionView.svg?style=flat)](https://cocoapods.org/pods/BECollectionView)
[![License](https://img.shields.io/cocoapods/l/BECollectionView.svg?style=flat)](https://cocoapods.org/pods/BECollectionView)
[![Platform](https://img.shields.io/cocoapods/p/BECollectionView.svg?style=flat)](https://cocoapods.org/pods/BECollectionView)

## Introduction

About `BECollectionView`:

- Creating `ListView` (`UITableView`, `UICollectionView`) in `UIKit` is a painful task which requires a lot of efforts. You firstly has to layout the `ListView`, create `Cell`, register it, bind data to data source and set up delegate. This type of actions is tedious and have to be repeated time to time.

- Plus, Using `UITableView` for larger screen sometimes is a bad idea, as its layout is not good for iPhone in landscape mode, and again, it requires a lot of efforts. So `BECollectionView` (with an embeded UICollectionView) is introduced to ease the process of creating "`ListView`" in `UIKit` by hiding most of settings of `UITableView`, `UICollectionView` (dataSource, delegate, registerCell, binding, ... ) and provide easy data-driven way to handle your `ListView`. `BECollectionView` can be use as a replacement of `UITableView` and `UICollectionView`.

- `BECollectionView` was born with the aim is to simplify the process of creating `ListView` by hiding the detail of `UIKit` `ListView`'s implemetation as much as posible, so you can concentrate on bussiness logic. After a few configurations, you got features like Pull to refresh, loading animation, add, remove, replace cells animation,... for free. The only thing that you need to care about is the flow of data.

## Features
Support both `RxSwift` and `Combine + SwiftConcurrency`

## Quick start

Open Demo project from `Demo` folder.

With a simple Model T, a BECollectionViewModel<T>, a BECollectionViewCell, you can create a data-driven UICollectionView easily with default behaviors like pull-to-refresh, reloading, refreshing, selecting...

![Example of working BECollectionView](https://user-images.githubusercontent.com/6975538/179670361-6a8f85ac-d25b-4dba-8f3a-6a4c45589125.gif)

Code:
```swift
// Model: Car.swift
struct Car: Hashable {
    var name: String
    var numberOfWheels: Int
}

// ViewModel: CarsViewModel
import BECollectionView_Combine

class CarsViewModel: BECollectionViewModel<Car> {
    override func createRequest() async throws -> [Car] {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate loading
        try Task.checkCancellation()
        return (0...Int.random(in: 1..<9)).map {.init(name: "Car#\($0)", numberOfWheels: Int.random(in: 1..<4))}
    }
}

// Cell: CarCell.swift
import BECollectionView_Core

class CarCell: UICollectionViewCell, BECollectionViewCell {
    var padding: UIEdgeInsets {.zero}
    public lazy var stackView = UIStackView(forAutoLayout: ())
    lazy var titleLabel = UILabel(forAutoLayout: ())
    lazy var descriptionLabel = UILabel(forAutoLayout: ())
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable,
    message: "Loading this view from a nib is unsupported in favor of initializer dependency injection."
    )
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func commonInit() {
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    open func setUp(with item: AnyHashable?) {
        guard let car = item as? Car else {
            titleLabel.text = "<placeholder>"
            descriptionLabel.text = "<placeholder>"
            return
        }
        titleLabel.text = car.name
        descriptionLabel.text = "\(car.numberOfWheels)"
    }
    
    func hideLoading() {
        stackView.hideLoader()
    }
    
    func showLoading() {
        stackView.showLoader()
    }
}

// ViewController.swift
BEStaticSectionsCollectionView(
    header: .init(
        viewType: GlobalHeaderView.self,
        heightDimension: .estimated(53)
    ),
    sections: [
        CarsSection(index: 0, viewModel: CombineCarsViewModel()),
        FriendsSection(index: 1, viewModel: CombineFriendsViewModel())
    ],
    footer: .init(
        viewType: GlobalFooterView.self,
        heightDimension: .estimated(53)
    )
)
```

## Requirements
- iOS >= 13

## Installation

BECollectionView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

For working with RxSwift
```ruby
pod 'BECollectionView', :git => 'https://github.com/bigearsenal/BECollectionView.git', :branch => 'master'
```

For working with Combine + Swift Concurrency
```ruby
pod 'BECollectionView_Combine', :git => 'https://github.com/bigearsenal/BECollectionView.git', :branch => 'master'
```

## How to implement `BECollectionView`

Import
```swift
import BECollectionView_Combine // For Combine project
import BECollectionView // For RxSwift project
import BECollectionView_Core // optional
```

### 1. Create a Model T
Assume that we have to create a collection of recipients, create a struct named `Recipient` to represent a record and conform it to `Hashable`:
```swift
struct Recipient: Hashable {
    let address: String
    let shortAddress: String
    let name: String?
}
```

### 2. Create a `CollectionViewModel`
Custom CollectionViewModel must be inheritted from `BECollectionViewModel<T>` (Combine + SwiftConcurrency) or `BEListViewModel<T>` (RxSwift).
This class is clearly a `ViewModel` that is responsible for data flow in `BECollectionView`. The only method that is required to be overridden is `createRequest`.

Example: Combine + SwiftConcurrency
```swift
import BECollectionView_Combine

class RecipientsListViewModel: BECollectionViewModel<Recipient> {
    // MARK: - Dependencies
    @Injected private var nameService: NameServiceType
    @Injected private var addressFormatter: AddressFormatterType
    
    // MARK: - Properties
    @Published var name: String = ""
    
    // MARK: - Methods
    /// The only methods that is REQUIRED to be inheritted
    override func createRequest() async throws -> [Recipient] {
        guard !name.isEmpty else {return .just([])}
        let result = try await nameService.getOwners(name)
        return result.map {
            Recipient(
                address: $0.owner,
                shortAddress: addressFormatter.shortAddress(of: $0.owner),
                name: $0.name
            )
        }
    }
}
```

Example: RxSwift
```swift
import RxSwift
import BECollectionView

class RecipientsListViewModel: BEListViewModel<Recipient> {
    // MARK: - Dependencies
    @Injected private var nameService: NameServiceType
    @Injected private var addressFormatter: AddressFormatterType
    
    // MARK: - Properties
    var name: String = ""
    
    // MARK: - Methods
    /// The only methods that is REQUIRED to be inheritted
    override func createRequest() -> Single<[Recipient]> {
        guard !name.isEmpty else {return .just([])}
        return nameService
            .getOwners(name)
            .map { [weak addressFormatter] in
                guard let addressFormatter = addressFormatter else { return [] }

                return $0.map {
                    Recipient(
                        address: $0.owner,
                        shortAddress: addressFormatter.shortAddress(of: $0.owner),
                        name: $0.name
                    )
                }
            }
    }
}
```

### 3. Create a UICollectionViewCell that conform to BECollectionViewCell
No need to explain, this class is required to have `setUp(with:)` to handling data presentation, `hideLoading()` and `showLoading()` for handling loading state.

```swift
import BECollectionView_Core

class RecipientCell: UICollectionViewCell, BECollectionViewCell {
    private let recipientView = RecipientView()
    
    ...
    
    // MARK: - BECollectionViewCell implementation
    func setUp(with item: AnyHashable?) {
        guard let recipient = item as? Recipient else {return}
        recipientView.setRecipient(recipient)
    }
    
    func hideLoading() {
        recipientView.hideLoader()
    }
    
    func showLoading() {
        recipientView.showLoader()
    }
}
```

### 4. (Optional) Header, Footer section
Example of creating Header, Footer view (as `UICollectionReusableView`s)
```swift
extension SelectRecipient {
    final class SectionHeaderView: UICollectionReusableView {
        private let titleLabel = UILabel(textSize: 15, weight: .medium, textColor: .a3a5ba)
        
        ...

        private func addSubviews() {
            [titleLabel].forEach(addSubview)
        }

        private func setConstraints() {
            ...
        }
    }
}
```

### 5. Create instance of `BECollectionView` or subclass it
There are 2 types of `BECollectionView`: `BEStaticSectionsCollectionView` and `BEDynamicSectionsCollectionView`. But you can concentrate on just `BEStaticSectionsCollectionView` right now, `BEDynamicSectionsCollectionView` will be explained later (Example: `TransactionsCollectionView`)

Now you have anything you need for a section in collection view: section header, footer (optional), cells and viewModel (for handling data flow), now you can construct a section:

```swift
let section: BEStaticSectionsCollectionView.Section = .init(
    index: 0,
    layout: .init(
        header: .init(viewClass: SectionHeaderView.self, heightDimension: .absolute(76)),
        cellType: RecipientCell.self,
        numberOfLoadingCells: 2
    ),
    viewModel: recipientsListViewModel
)
```

After that you can create an instance of `BEStaticSectionsCollectionView` or subclass it (but i recommend you to subclass it for easily modifying header, footer in section):

```swift
extension SelectRecipient {
    final class RecipientsCollectionView: BEStaticSectionsCollectionView {
        // MARK: - Dependencies
        private let recipientsListViewModel: RecipientsListViewModel
        
        // MARK: - Initializer
        init(recipientsListViewModel: RecipientsListViewModel) {
            self.recipientsListViewModel = recipientsListViewModel
            
            let section: BEStaticSectionsCollectionView.Section = .init(...)
            
            super.init(
                header: nil,
                sections: [section],
                footer: nil
            )
        }
        
        // MARK: -
        
        /// Do anything after a snapshot of data has been loaded (update header for example)
        override func dataDidLoad() {
            super.dataDidLoad()
//            let header = sectionHeaderView(sectionIndex: 0) as? SectionHeaderView {
//                // do something with header
//            }
        }
    }
}

// ViewController.swift
private lazy var recipientCollectionView: RecipientsCollectionView = {
    let collectionView = RecipientsCollectionView(recipientsListViewModel: recipientsListViewModel)
    collectionView.delegate = self
    return collectionView
}()

```

### 6. Delegation
```swift
extension SelectRecipient.RootView: BECollectionViewDelegate {
    func beCollectionView(collectionView: BECollectionViewBase, didSelect item: AnyHashable) {
        guard let recipient = item as? Recipient else {return}
        viewModel.recipientSelected(recipient)
    }
}
```

## Controll data flow
After adding `RecipientsCollectionView`, and setting up `RecipientsListViewModel`, you can controll it's data flow by injecting data and calling method `reload()` on listViewModel like this:

Example: Combine + SwiftConcurrency
```swift
@Published var searchText: String = ""
...
$searchText
    .sink {[weak self] searchText in
        self?.recipientsListViewModel.name = searchText
        self?.recipientsListViewModel.reload()
    }
    .stored(in: &subscriptions)
```

Example: RxSwift
```swift
recipientSearchSubject
    .subscribe(
        onNext: { [weak self] searchText in
            self?.recipientsListViewModel.name = searchText
            self?.recipientsListViewModel.reload()
        }
    )
    .disposed(by: disposeBag)
```

## What you got after doing this?
- Pull to refresh by default (can be turned off)
- Loading cell shown when data is loading
- 2 columns in landscape mode

## Disclaimer
- I know that `UIKit` is dying and being replaced by `SwiftUI`. `SwiftUI` has very clarify way to define `ListView` with lack of efforts, but it is right now unstable for iOS13, so I think `BECollectionView` is a good solution right now for easily implementing `ListView` in `UIKit` for iOS earlier than iOS15.
- This lib is in early state of developing, API may be changed frequently.
- If you have any idea, please constribute.

## Author

Chung Tran, bigearsenal@gmail.com

## License

BECollectionView is available under the MIT license. See the LICENSE file for more info.
