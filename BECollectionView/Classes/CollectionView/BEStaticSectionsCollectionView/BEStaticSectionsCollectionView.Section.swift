//
//  BEStaticSectionsCollectionView.Section.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift

extension BEStaticSectionsCollectionView {
    open class Section {
        // MARK: - Properties
        public weak var collectionView: BECollectionViewBase?
        public let index: Int
        public var layout: BECollectionViewSectionLayout
        public let viewModel: BEListViewModelType
        public let customFilter: ((AnyHashable) -> Bool)?
        public let limit: (([AnyHashable]) -> [AnyHashable])?
        public init(
            index: Int,
            layout: BECollectionViewSectionLayout,
            viewModel: BEListViewModelType,
            customFilter: ((AnyHashable) -> Bool)? = nil,
            limit: (([AnyHashable]) -> [AnyHashable])? = nil
        ) {
            self.index = index
            self.layout = layout
            self.viewModel = viewModel
            self.customFilter = customFilter
            self.limit = limit
        }
        
        // MARK: - Set up
        func registerCellAndSupplementaryViews() {
            layout.registerCellsAndSupplementaryViews(in: collectionView!.collectionView, emptyCellIdentifier: emptyCellIdentifier, headerIdentifier: headerIdentifier, footerIdentifier: footerIdentifier)
        }
        
        func configureSupplementaryView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
            if kind == UICollectionView.elementKindSectionHeader {
                return configureHeader(indexPath: indexPath)
            }
            if kind == UICollectionView.elementKindSectionFooter {
                return configureFooter(indexPath: indexPath)
            }
            return nil
        }
        
        open func configureHeader(indexPath: IndexPath) -> UICollectionReusableView? {
            let view = layout.configureHeader(in: collectionView!.collectionView, indexPath: indexPath, headerIdentifier: headerIdentifier)
            return view
        }
        
        open func configureFooter(indexPath: IndexPath) -> UICollectionReusableView? {
            let view = layout.configureFooter(in: collectionView!.collectionView, indexPath: indexPath, footerIdentifier: footerIdentifier)
            
            return view
        }
        
        open func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell {
            layout.configureCell(collectionView: collectionView, indexPath: indexPath, item: item, emptyCellIdentifier: emptyCellIdentifier)
        }
        
        // MARK: - Datasource
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
                for i in 0..<layout.numberOfLoadingCells {
                    collectionViewItems.append(BECollectionViewItem(placeholderIndex: UUID().uuidString))
                }
            case .loaded:
                if collectionViewItems.isEmpty, layout.emptyCellType != nil {
                    collectionViewItems = [BECollectionViewItem(emptyCellIndex: UUID().uuidString)]
                }
            case .error:
                break
            }
            return collectionViewItems
        }
        
        // MARK: - Getters
        public func headerView() -> UICollectionReusableView? {
            collectionView?.sectionHeaderView(sectionIndex: index)
        }
        
        public func footerView() -> UICollectionReusableView? {
            collectionView?.sectionFooterView(sectionIndex: index)
        }
        
        // MARK: - Actions
        open func reload() {
            viewModel.reload()
        }
        
        open func dataDidLoad() {
            
        }
        
        // MARK: - CollectionView
        public var collectionViewLayout: UICollectionViewLayout? {
            collectionView?.collectionView.collectionViewLayout
        }
        
        // MARK: - Helper
        private var headerIdentifier: String {
            "Header#\(index)"
        }
        
        private var footerIdentifier: String {
            "Footer#\(index)"
        }
        
        private var emptyCellIdentifier: String {
            "EmptyCell#\(index)"
        }
    }
}
