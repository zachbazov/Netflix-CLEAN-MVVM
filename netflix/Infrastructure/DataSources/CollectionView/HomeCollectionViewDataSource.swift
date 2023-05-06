//
//  HomeCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var collectionView: UICollectionView? { get }
    var coordinator: HomeViewCoordinator { get }
    var section: Section { get }
    
    func didLoad()
    func dataSourceDidChange()
}

// MARK: - HomeCollectionViewDataSource Type

final class HomeCollectionViewDataSource<Cell>: NSObject,
                                                UICollectionViewDelegate,
                                                UICollectionViewDataSource,
                                                UICollectionViewDataSourcePrefetching where Cell: UICollectionViewCell {
    fileprivate weak var collectionView: UICollectionView?
    fileprivate let coordinator: HomeViewCoordinator
    fileprivate let section: Section
    
    /// Create home's collection view data source object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - section: Corresponding media's section object.
    ///   - viewModel: Coordinating view model.
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
        
        self.didLoad()
    }
    
    deinit {
        print("deinit \(Self.self)")
    }
    
    // MARK: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDataSourcePrefetching Implementation
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CollectionViewCell.create(on: collectionView,
                                         reuseIdentifier: Cell.reuseIdentifier,
                                         section: section,
                                         for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let homeViewModel = coordinator.viewController?.viewModel else { return }
        
        let media = section.media[indexPath.row]
        
        homeViewModel.detailSection = section
        homeViewModel.detailMedia = media
        homeViewModel.shouldScreenRotate = false
        
        coordinator.coordinate(to: .detail)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {}
}

// MARK: - DataSourceProtocol Implementation

extension HomeCollectionViewDataSource: DataSourceProtocol {
    fileprivate func didLoad() {
        dataSourceDidChange()
    }
    
    fileprivate func dataSourceDidChange() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.prefetchDataSource = self
        collectionView?.reloadData()
    }
}
