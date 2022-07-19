//
//  CombineStaticSectionsCollectionView.FriendsSection.swift
//  BECollectionView-Demo
//
//  Created by Chung Tran on 19/07/2022.
//

import Foundation
import UIKit
import BECollectionView_Core
import BECollectionView_Combine

extension CombineStaticSectionsCollectionView {
    class FriendsSection: BEStaticSectionsCollectionView.Section {
        init(index: Int, viewModel: BECollectionViewModelType) {
            super.init(
                index: index,
                layout: .init(
                    cellType: FriendCell.self,
                    emptyCellType: BECollectionViewBasicEmptyCell.self,
                    interGroupSpacing: 16,
                    contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10),
                    horizontalInterItemSpacing: .fixed(16),
                    customLayoutForGroupOnSmallScreen: {_ in
                        Self.groupLayoutForFriendSection()
                    },
                    customLayoutForGroupOnLargeScreen: {_ in
                        Self.groupLayoutForFriendSection()
                }),
                viewModel: viewModel
            )
        }
        
        private static func groupLayoutForFriendSection() -> NSCollectionLayoutGroup {
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(80), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(89))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(16)
            return group
        }
    }
}
