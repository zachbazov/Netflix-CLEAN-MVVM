//
//  UserProfileCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - UserProfileCollectionViewDataSource Type

final class UserProfileCollectionViewDataSource: CollectionViewDataSource {
    
    private let viewModel: ProfileViewModel
    
    private weak var collectionView: UICollectionView?
    
    init(for collectionView: UICollectionView, with viewModel: ProfileViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return viewModel.profiles.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return UserProfileCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel) as! T
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T : UICollectionViewCell {
        cell.opacityAnimation()
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? UserProfileCollectionViewCell else { return }
        
        cell.didSelect()
    }
}

// MARK: - Internal Implementation

extension UserProfileCollectionViewDataSource {
    func dataSourceDidChange() {
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
