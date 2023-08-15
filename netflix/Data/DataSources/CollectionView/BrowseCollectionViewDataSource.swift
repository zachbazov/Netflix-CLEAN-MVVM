//
//  BrowseCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 23/05/2023.
//

import UIKit

// MARK: - BrowseOverlayCollectionViewDataSource Type

final class BrowseOverlayCollectionViewDataSource: CollectionViewDataSource {
    
    fileprivate let viewModel: BrowseOverlayViewModel
    
    init(viewModel: BrowseOverlayViewModel) {
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return viewModel.section.value.media.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let homeViewController = Application.app.coordinator.tabCoordinator?.home?.viewControllers.first as? HomeViewController,
              let homeViewModel = homeViewController.viewModel
        else { fatalError() }
        return MediaCollectionViewCell.create(of: StandardCollectionViewCell.self,
                                               on: collectionView,
                                               reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
                                               section: viewModel.section.value,
                                               for: indexPath,
                                               with: homeViewModel) as! T
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}
