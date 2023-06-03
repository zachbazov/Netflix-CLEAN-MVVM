//
//  AccountProfileCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import UIKit

// MARK: - AccountProfileCollectionViewDataSource Type

final class AccountProfileCollectionViewDataSource: CollectionViewDataSource {
    
    private let viewModel: AccountViewModel
    
    init(with viewModel: AccountViewModel) {
        self.viewModel = viewModel
        
        super.init()
        
        self.dataSourceDidChange()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return viewModel.profiles.value.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T : UICollectionViewCell {
        return AccountProfileCollectionViewCell.create(of: AccountProfileCollectionViewCell.self,
                                                on: collectionView,
                                                for: indexPath,
                                                with: viewModel) as! T
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension AccountProfileCollectionViewDataSource {
    func dataSourceDidChange() {
        guard let collectionView = viewModel.coordinator?.viewController?.collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
