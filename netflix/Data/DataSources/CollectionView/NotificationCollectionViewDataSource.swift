//
//  NotificationCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 12/03/2023.
//

import UIKit

// MARK: - NotificationCollectionViewDataSource Type

final class NotificationCollectionViewDataSource: CollectionViewDataSource {
    private let viewModel: MyNetflixViewModel
    
    fileprivate weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView, with viewModel: MyNetflixViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }

    override func numberOfItems(in section: Int) -> Int {
        return 1
    }

    override func cellForItem<T>(in collectionView: UICollectionView,
                                 at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return NotificationCollectionViewCell.create(of: NotificationCollectionViewCell.self,
                                                     on: collectionView,
                                                     for: indexPath,
                                                     with: viewModel) as! T
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension NotificationCollectionViewDataSource {
    func dataSourceDidChange(at indexPaths: [IndexPath]) {
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadItems(at: indexPaths)
    }
}
