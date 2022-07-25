//
//  BEStaticSectionsCollectionView.Section.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import UIKit
import BECollectionView_Core

extension BEStaticSectionsCollectionView {
    open class Section: BEStaticSection {
        // MARK: - Properties
        public let viewModel: BECollectionViewModelType
        
        public init(
            index: Int,
            layout: BECollectionViewSectionLayout,
            viewModel: BECollectionViewModelType,
            customFilter: ((AnyHashable) -> Bool)? = nil,
            limit: (([AnyHashable]) -> [AnyHashable])? = nil
        ) {
            self.viewModel = viewModel
            super.init(index: index, layout: layout, customFilter: customFilter, limit: limit)
        }
        
        // MARK: - Datasource
        open override func convertDataToAnyHashable() -> [AnyHashable] {
            viewModel.convertDataToAnyHashable()
        }
        
        open override func getCurrentState() -> BEFetcherState {
            viewModel.state
        }
        
        // MARK: - Actions
        open override func reload() {
            viewModel.reload()
        }
    }
}
