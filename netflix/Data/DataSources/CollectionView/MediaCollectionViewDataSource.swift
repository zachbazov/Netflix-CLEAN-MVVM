//
//  MediaCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - MediaCollectionViewDataSource Type

final class MediaCollectionViewDataSource<Cell>: CollectionViewDataSource,
                                                 UICollectionViewDataSourcePrefetching where Cell: UICollectionViewCell {
    fileprivate let coordinator: HomeViewCoordinator
    fileprivate let section: Section
    
    init(section: Section, viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else {
            fatalError("Unexpected \(type(of: viewModel.coordinator)) coordinator value.")
        }
        
        self.coordinator = coordinator
        self.section = section
        
        super.init()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return self.section.media.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return MediaCollectionViewCell.create(of: MediaCollectionViewCell.self,
                                               on: collectionView,
                                               reuseIdentifier: Cell.reuseIdentifier,
                                               section: section,
                                               for: indexPath,
                                               with: coordinator.viewController?.viewModel) as! T
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        coordinator.coordinate(to: .detail)
        
        guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        let media = section.media[indexPath.row]
        
        controller.viewModel.media = media
        controller.viewModel.section = section
        controller.viewModel.isRotated = false
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
    
    // MARK: UICollectionViewDataSourcePrefetching Implementation
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {}
}

// MARK: - Private Implementation

extension MediaCollectionViewDataSource {}
