//
//  BEStaticSectionsCollectionView.Section.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift

extension BEStaticSectionsCollectionView {
    open class Section: BECollectionViewSectionBase {
        public let viewModel: BEListViewModelType
        public init(
            index: Int,
            layout: BECollectionViewSectionLayout,
            viewModel: BEListViewModelType,
            customFilter: ((AnyHashable) -> Bool)? = nil,
            limit: (([AnyHashable]) -> [AnyHashable])? = nil
        ) {
            self.viewModel = viewModel
            super.init(index: index, layout: layout, customFilter: customFilter, limit: limit)
        }
        
        open func mapDataToCollectionViewItems() -> [BECollectionViewItem]
        {
            var items = viewModel.convertDataToAnyHashable()
                
            if let customFilter = customFilter {
                items = items.filter {customFilter($0)}
            }
            
            if let limit = limit {
                items = limit(items)
            }
            
            var collectionViewItems = items
                .map {BECollectionViewItem(value: $0)}
            switch viewModel.currentState {
            case .loading, .initializing:
                collectionViewItems += [
                    BECollectionViewItem(placeholderIndex: UUID().uuidString),
                    BECollectionViewItem(placeholderIndex: UUID().uuidString)
                ]
            case .loaded:
                if collectionViewItems.isEmpty, layout.emptyCellType != nil {
                    collectionViewItems = [BECollectionViewItem(emptyCellIndex: UUID().uuidString)]
                }
            case .error:
                break
            }
            return collectionViewItems
        }
        
        open func reload() {
            viewModel.reload()
        }
        
        open func dataDidLoad() {
            
        }
    }
}
