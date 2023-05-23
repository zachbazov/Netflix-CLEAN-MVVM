//
//  ProfileCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import UIKit

// MARK: - ProfileCollectionViewDataSource Type

final class ProfileCollectionViewDataSource: CollectionViewDataSource<ProfileCollectionViewCell, ProfileCollectionViewCellViewModel> {
    private let viewModel: AccountViewModel
    
    init(with viewModel: AccountViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.dataSourceDidChange()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems() -> Int {
        return viewModel.profiles.value.count
    }
    
    override func cellForItem(in collectionView: UICollectionView, at indexPath: IndexPath) -> ProfileCollectionViewCell {
        return ProfileCollectionViewCell.create(of: ProfileCollectionViewCell.self,
                                                on: collectionView,
                                                for: indexPath,
                                                with: viewModel)
    }
    
    override func willDisplayCellForItem(_ cell: ProfileCollectionViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension ProfileCollectionViewDataSource {
    func dataSourceDidChange() {
        guard let collectionView = viewModel.coordinator?.viewController?.collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
