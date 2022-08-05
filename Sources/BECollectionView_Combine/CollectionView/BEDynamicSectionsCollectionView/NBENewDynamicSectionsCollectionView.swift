import Foundation
import UIKit
import BECollectionView_Core

open class NBENewDynamicSectionsCollectionView: BEDynamicSectionsCollectionView {
    public typealias HeaderBuilder = (_ view: UICollectionReusableView?, _ sectionInfo: BEDynamicSectionsCollectionView.SectionInfo?) -> Void
    public typealias FooterBuilder = (_ view: UICollectionReusableView?, _ sectionInfo: BEDynamicSectionsCollectionView.SectionInfo?) -> Void
    
    private let headerBuilder: HeaderBuilder?
    private let footerBuilder: FooterBuilder?
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        viewModel: BECollectionViewModelType,
        mapDataToSections: @escaping (BECollectionViewModelType) -> [BEDynamicSectionsCollectionView.SectionInfo],
        layout: BECollectionViewSectionLayout,
        headerBuilder: HeaderBuilder? = nil,
        footerBuilder: FooterBuilder? = nil,
        footer: BECollectionViewHeaderFooterViewLayout? = nil
    ) {
        self.headerBuilder = headerBuilder
        self.footerBuilder = footerBuilder
        super.init(
            header: header,
            viewModel: viewModel,
            mapDataToSections: mapDataToSections,
            layout: layout,
            footer: footer
        )
    }
    
    open override func configureSectionHeaderView(view: UICollectionReusableView?, sectionIndex: Int) {
        if sectionIndex < sections.count {
            headerBuilder?(view, sections[sectionIndex])
        } else {
            headerBuilder?(view, nil)
        }
    }
    
    open override func configureSectionFooterView(view: UICollectionReusableView?, sectionIndex: Int) {
        if sectionIndex < sections.count {
            footerBuilder?(view, sections[sectionIndex])
        } else {
            footerBuilder?(view, nil)
        }
    }
    
    public func withDelegate(_ delegate: BECollectionViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }
}

