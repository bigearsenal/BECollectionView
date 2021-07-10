//
//  BECollectionViewSectionBase.swift
//  BECollectionView
//
//  Created by Chung Tran on 09/07/2021.
//

import Foundation

open class BECollectionViewSectionBase {
    public weak var collectionView: BECollectionViewBase?
    public let index: Int
    public var layout: BECollectionViewSectionLayout
    public let customFilter: ((AnyHashable) -> Bool)?
    public let limit: (([AnyHashable]) -> [AnyHashable])?
    
    public init(
        index: Int,
        layout: BECollectionViewSectionLayout,
        customFilter: ((AnyHashable) -> Bool)? = nil,
        limit: (([AnyHashable]) -> [AnyHashable])? = nil
    ) {
        self.index = index
        self.layout = layout
        self.customFilter = customFilter
        self.limit = limit
    }
    
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
