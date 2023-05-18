//
//  CollectionReusableView.swift
//  netflix
//
//  Created by Zach Bazov on 18/05/2023.
//

import UIKit

// MARK: - CollectionReusableView Type

class CollectionReusableView: UICollectionReusableView {
    class func create<T>(in collectionView: UICollectionView,
                         at indexPath: IndexPath) -> T {
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
    
    func viewDidLoad() {}
    func viewHierarchyWillConfigure() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionReusableView: ViewLifecycleBehavior {}

// MARK: - Reusable Implementation

extension CollectionReusableView: Reusable {}
