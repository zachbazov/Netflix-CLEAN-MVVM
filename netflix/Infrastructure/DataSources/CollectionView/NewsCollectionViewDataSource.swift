//
//  NewsCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: NewsViewModel { get }
    var numberOfSections: Int { get }
    
    func dataSourceDidChange()
}

// MARK: - NewsCollectionViewDataSource Type

final class NewsCollectionViewDataSource: NSObject {
    fileprivate let viewModel: NewsViewModel
    fileprivate let numberOfSections: Int = 1
    /// Create a news table view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - DataSourceProtocol Implementation

extension NewsCollectionViewDataSource: DataSourceProtocol {
    func dataSourceDidChange() {
        guard let collectionView = viewModel.coordinator!.viewController!.collectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource Implementation

extension NewsCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return NewsCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let row = indexPath.row as Int?, row >= 0, row <= viewModel.items.value.count - 1 else { return }
        let homeNavigation = Application.app.coordinator.tabCoordinator.home!
        let newsNavigation = Application.app.coordinator.tabCoordinator.news!
        let homeController = homeNavigation.viewControllers.first! as! HomeViewController
        let homeViewModel = homeController.viewModel
        let newsController = newsNavigation.viewControllers.first! as! NewsViewController
        let newsCoordinator = newsController.viewModel.coordinator!
        let cellViewModel = viewModel.items.value[row]
        let section = homeViewModel?.section(at: .resumable)
        newsCoordinator.section = section
        newsCoordinator.media = cellViewModel.media
        newsCoordinator.shouldScreenRotate = false
        newsCoordinator.coordinate(to: .detail)
    }
}
