import Foundation
import UIKit

public struct BECollectionViewSeparatorLayout {
    public static let elementKind = "BECollectionViewSeparator"
    
    public init(
        identifier: String? = nil,
        viewClass: UICollectionReusableView.Type = UICollectionReusableView.self,
        heightDimension: NSCollectionLayoutDimension = .absolute(1),
        customLayout: NSCollectionLayoutBoundarySupplementaryItem? = nil
    ) {
        self.identifier = identifier ?? String(describing: viewClass)
        self.viewClass = viewClass
        self.heightDimension = heightDimension
        self.customLayout = customLayout
    }
    
    public let identifier: String
    public let viewClass: UICollectionReusableView.Type
    public let heightDimension: NSCollectionLayoutDimension
    public let customLayout: NSCollectionLayoutBoundarySupplementaryItem?
    public var layout: NSCollectionLayoutSupplementaryItem {
        if let layout = customLayout {return layout}
        
        let separatorAnchor = NSCollectionLayoutAnchor(edges: .bottom, absoluteOffset: CGPoint(x: 0, y: 1))
        let separatorSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: heightDimension)
        return NSCollectionLayoutSupplementaryItem(layoutSize: separatorSize, elementKind: Self.elementKind, containerAnchor: separatorAnchor)
    }
}
