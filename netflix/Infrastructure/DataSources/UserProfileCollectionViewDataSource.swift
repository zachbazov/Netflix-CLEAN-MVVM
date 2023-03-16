//
//  UserProfileCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - UserProfileCollectionViewDataSource Type

final class UserProfileCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private weak var collectionView: UICollectionView?
    private let viewModel: ProfileViewModel
    
    init(for collectionView: UICollectionView, with viewModel: ProfileViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    func dataSourceDidChange() {
        guard let collectionView = collectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.profiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UserProfileCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel)
    }
}
