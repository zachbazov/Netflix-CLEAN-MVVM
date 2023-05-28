//
//  CollectionReusableView.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - CollectionReusableView Type

protocol CollectionReusableView: UICollectionReusableView, ViewLifecycleBehavior, Reusable {}

// MARK: - CollectionReusableView Implementation

extension CollectionReusableView {
    static func create<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath) as? T
        else { fatalError() }
        
        switch cell {
        case let cell as LabeledCollectionHeaderView:
            cell.viewDidLoad()
        default: break
        }
        
        return cell
    }
}
