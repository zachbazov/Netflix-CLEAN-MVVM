//
//  ProfileCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - ProfileCollectionViewDataSource Type

final class ProfileCollectionViewDataSource: CollectionViewDataSource {
    let viewModel: ProfileViewModel
    let collectionView: UICollectionView
    
    init(for collectionView: UICollectionView, with viewModel: ProfileViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    deinit {
        printIfDebug(.debug, "deinit \(Self.self)")
        
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.removeFromSuperview()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return viewModel.profiles.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return ProfileCollectionViewCell.create(of: ProfileCollectionViewCell.self, on: collectionView, for: indexPath, with: viewModel) as! T
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T : UICollectionViewCell {
        cell.opacityAnimation()
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell else { return }
        
        cell.didSelect()
    }
}

// MARK: - Internal Implementation

extension ProfileCollectionViewDataSource {
    func dataSourceDidChange() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
