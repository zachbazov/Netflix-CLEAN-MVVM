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
    
    private let numOfSections: Int = 1
    
    deinit {
        print("deinit \(String(describing: Self.self))")
    }
    
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
        return numOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.profiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UserProfileCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? UserProfileCollectionViewCell else { return }
        cell.didSelect()
    }
}
