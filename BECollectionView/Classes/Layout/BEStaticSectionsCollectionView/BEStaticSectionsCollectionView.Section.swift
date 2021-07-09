//
//  BEStaticSectionsCollectionView.Section.swift
//  BECollectionView
//
//  Created by Chung Tran on 15/03/2021.
//

import Foundation
import RxSwift

@available(*, deprecated, renamed: "BEStaticSectionsCollectionView.Section")
open class BECollectionViewSection {}

extension BEStaticSectionsCollectionView {
    open class Section {
        public weak var collectionView: BEStaticSectionsCollectionView?
        public let index: Int
        public let layout: SectionLayout
        public let viewModel: BEListViewModelType
        public let customFilter: ((AnyHashable) -> Bool)?
        public let limit: (([AnyHashable]) -> [AnyHashable])?
        
        public init(
            index: Int,
            layout: SectionLayout,
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
        
        func registerCellAndSupplementaryViews() {
            // register cell
            collectionView?.collectionView.register(layout.cellType, forCellWithReuseIdentifier: String(describing: layout.cellType))
            collectionView?.collectionView
                .register(layout.emptyCellType, forCellWithReuseIdentifier: emptyCellIdentifier)
            
            // register header
            if let header = layout.header?.viewClass {
                collectionView?.collectionView.register(header, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
            }
            
            
            // register footer
            if let footer = layout.footer?.viewClass {
                collectionView?.collectionView.register(footer, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
            }
            
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
            let view = collectionView?.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: headerIdentifier,
                for: indexPath)
            return view
        }
        
        open func configureFooter(indexPath: IndexPath) -> UICollectionReusableView? {
            let view = collectionView?.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: footerIdentifier,
                for: indexPath)
            
            return view
        }
        
        open func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell {
            
            if !item.isEmptyCell,
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: layout.cellType), for: indexPath) as? BECollectionViewCell {
                cell.setUp(with: item.value)
                
                if item.isPlaceholder {
                    cell.hideLoading()
                    cell.showLoading()
                } else {
                    cell.hideLoading()
                }
                
                return cell
            }
            
            if item.isEmptyCell {
                return collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellIdentifier, for: indexPath)
            }
            
            return UICollectionViewCell()
        }
        
        open func reload() {
            viewModel.reload()
        }
        
        open func dataDidLoad() {
            
        }
        
        public func headerView() -> UICollectionReusableView? {
            collectionView?.sectionHeaderView(sectionIndex: index)
        }
        
        public func footerView() -> UICollectionReusableView? {
            collectionView?.sectionFooterView(sectionIndex: index)
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
