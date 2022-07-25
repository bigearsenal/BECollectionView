import Foundation
import UIKit

open class BECollectionViewDefaultSeparatorView: UICollectionReusableView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.frame = layoutAttributes.frame
    }
}
