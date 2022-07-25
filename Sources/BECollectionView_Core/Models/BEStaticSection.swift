import Foundation
import UIKit

open class BEStaticSection {
    // MARK: - Properties
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
    
    // MARK: - Set up
    public func registerCellAndSupplementaryViews() {
        layout.registerCellsAndSupplementaryViews(in: collectionView!.collectionView, emptyCellIdentifier: emptyCellIdentifier, headerIdentifier: headerIdentifier, footerIdentifier: footerIdentifier)
    }
    
    public func configureSupplementaryView(kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader {
            return configureHeader(indexPath: indexPath)
        }
        if kind == UICollectionView.elementKindSectionFooter {
            return configureFooter(indexPath: indexPath)
        }
        if kind.starts(with: BECollectionViewSeparatorLayout.elementKind) {
            return configureSeparator(indexPath: indexPath, separatorElementKind: kind)
        }
        return nil
    }
    
    open func configureHeader(indexPath: IndexPath) -> UICollectionReusableView? {
        layout.configureHeader(in: collectionView!.collectionView, indexPath: indexPath, headerIdentifier: headerIdentifier)
    }
    
    open func configureFooter(indexPath: IndexPath) -> UICollectionReusableView? {
        layout.configureFooter(in: collectionView!.collectionView, indexPath: indexPath, footerIdentifier: footerIdentifier)
    }
    
    open func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: BECollectionViewItem) -> UICollectionViewCell {
        layout.configureCell(collectionView: collectionView, indexPath: indexPath, item: item, emptyCellIdentifier: emptyCellIdentifier)
    }
    
    open func configureSeparator(indexPath: IndexPath, separatorElementKind: String) -> UICollectionReusableView? {
        layout.configureSeparator(collectionView: collectionView!.collectionView, indexPath: indexPath, separatorElementKind: separatorElementKind)
    }
    
    // MARK: - Datasource
    open func convertDataToAnyHashable() -> [AnyHashable] {
        fatalError("Must override")
    }
    
    open func getCurrentState() -> BEFetcherState {
        fatalError("Must override")
    }
    
    open func mapDataToCollectionViewItems() -> [BECollectionViewItem]
    {
        var items = convertDataToAnyHashable()
            
        if let customFilter = customFilter {
            items = items.filter {customFilter($0)}
        }
        
        if let limit = limit {
            items = limit(items)
        }
        
        var collectionViewItems = items
            .map {BECollectionViewItem(value: $0)}
        switch getCurrentState() {
        case .loading, .initializing:
            for _ in 0..<layout.numberOfLoadingCells {
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
        fatalError("Must override")
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
