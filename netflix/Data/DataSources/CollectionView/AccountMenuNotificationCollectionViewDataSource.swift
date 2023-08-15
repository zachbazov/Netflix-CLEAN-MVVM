//
//  AccountMenuNotificationCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 12/03/2023.
//

import UIKit

// MARK: - AccountMenuNotificationCollectionViewDataSource Type

final class AccountMenuNotificationCollectionViewDataSource: CollectionViewDataSource {
    private let viewModel: AccountViewModel
    
    fileprivate weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView, with viewModel: AccountViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }

    override func numberOfItems(in section: Int) -> Int {
        return viewModel.menuItems[section].options?.count ?? 0
    }

    override func cellForItem<T>(in collectionView: UICollectionView,
                                 at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return AccountMenuNotificationCollectionViewCell.create(of: AccountMenuNotificationCollectionViewCell.self,
                                                                on: collectionView,
                                                                for: indexPath,
                                                                with: viewModel) as! T
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension AccountMenuNotificationCollectionViewDataSource {
    func dataSourceDidChange(at indexPaths: [IndexPath]) {
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadItems(at: indexPaths)
    }
}
