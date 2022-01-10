//
//  BENewDynamicSectionsCollectionView.swift
//  BECollectionView
//
//  Created by Giang Long Tran on 06.01.22.
//

import Foundation
import RxSwift

open class NBENewDynamicSectionsCollectionView: BEDynamicSectionsCollectionView {
    public typealias HeaderBuilder = (_ view: UICollectionReusableView?, _ sectionInfo: BEDynamicSectionsCollectionView.SectionInfo) -> Void
    public typealias FooterBuilder = (_ view: UICollectionReusableView?, _ sectionInfo: BEDynamicSectionsCollectionView.SectionInfo) -> Void
    
    private let headerBuilder: HeaderBuilder?
    private let footerBuilder: FooterBuilder?
    
    // MARK: - Initializer
    public init(
        header: BECollectionViewHeaderFooterViewLayout? = nil,
        viewModel: BEListViewModelType,
        mapDataToSections: @escaping (BEListViewModelType) -> [BEDynamicSectionsCollectionView.SectionInfo],
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
        headerBuilder?(view, sections[sectionIndex])
    }
    
    open override func configureSectionFooterView(view: UICollectionReusableView?, sectionIndex: Int) {
        footerBuilder?(view, sections[sectionIndex])
    }
}

