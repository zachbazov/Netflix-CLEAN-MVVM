//
//  MediaCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var collectionView: UICollectionView? { get }
    var section: Section { get }
}

// MARK: - MediaCollectionViewDataSource Type

final class MediaCollectionViewDataSource<Cell>: CollectionViewDataSource<MediaCollectionViewCell, MediaCollectionViewCellViewModel>, UICollectionViewDataSourcePrefetching where Cell: UICollectionViewCell {
    fileprivate let coordinator: HomeViewCoordinator
    fileprivate let section: Section
    
    fileprivate weak var collectionView: UICollectionView?
    
    init(on collectionView: UICollectionView,
         section: Section,
         viewModel: HomeViewModel) {
        guard let coordinator = viewModel.coordinator else {
            fatalError("Unexpected \(type(of: viewModel.coordinator)) coordinator value.")
        }
        
        self.coordinator = coordinator
        self.section = section
        self.collectionView = collectionView
        
        super.init()
        
        self.dataSourceDidChange()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems() -> Int {
        return section.media.count
    }
    
    override func cellForItem(in collectionView: UICollectionView, at indexPath: IndexPath) -> MediaCollectionViewCell {
        return MediaCollectionViewCell.create(of: MediaCollectionViewCell.self,
                                               on: collectionView,
                                               reuseIdentifier: Cell.reuseIdentifier,
                                               section: section,
                                               for: indexPath)
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        coordinator.coordinate(to: .detail)
        
        guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        let media = section.media[indexPath.row]
        
        controller.viewModel.media = media
        controller.viewModel.section = section
        controller.viewModel.isRotated = false
    }
    
    override func willDisplayCellForItem(_ cell: MediaCollectionViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    // MARK: UICollectionViewDataSourcePrefetching Implementation
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {}
}

// MARK: - DataSourceProtocol Implementation

extension MediaCollectionViewDataSource: DataSourceProtocol {}

// MARK: - Private Implementation

extension MediaCollectionViewDataSource {
    private func dataSourceDidChange() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.prefetchDataSource = self
        collectionView?.reloadData()
    }
}
