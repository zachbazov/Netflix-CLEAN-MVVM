//
//  BrowseCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 23/05/2023.
//

import UIKit

// MARK: - BrowseOverlayCollectionViewDataSource Type

final class BrowseOverlayCollectionViewDataSource: CollectionViewDataSource<StandardCollectionViewCell, PosterCollectionViewCellViewModel> {
    fileprivate let viewModel: BrowseOverlayViewModel
    
    init(viewModel: BrowseOverlayViewModel) {
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems() -> Int {
        return viewModel.section.value.media.count
    }
    
    override func cellForItem(in collectionView: UICollectionView,
                              at indexPath: IndexPath) -> StandardCollectionViewCell {
        return PosterCollectionViewCell.create(of: StandardCollectionViewCell.self,
                                               on: collectionView,
                                               reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
                                               section: viewModel.section.value,
                                               for: indexPath)
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
    }
    
    override func willDisplayCellForItem(_ cell: StandardCollectionViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
}
