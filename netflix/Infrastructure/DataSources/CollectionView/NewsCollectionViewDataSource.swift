//
//  NewsCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - NewsCollectionViewDataSource Type

final class NewsCollectionViewDataSource: CollectionViewDataSource {
    
    fileprivate let viewModel: NewsViewModel
    
    /// Create a news table view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return NewsCollectionViewCell.create(of: NewsCollectionViewCell.self,
                                             on: collectionView,
                                             for: indexPath,
                                             with: viewModel) as! T
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let row = indexPath.row as Int?, row >= 0, row <= viewModel.items.value.count - 1 else { return }
        
        let tabCoordinator = Application.app.coordinator.tabCoordinator
        
        guard let homeController = tabCoordinator.home?.viewControllers.first as? HomeViewController,
              let newsController = tabCoordinator.news?.viewControllers.first as? NewsViewController
        else { return }
        
        let cellViewModel = viewModel.items.value[row]
        let section = homeController.viewModel?.section(at: .newRelease)
        
        newsController.viewModel.section = section
        newsController.viewModel.media = cellViewModel.media
        newsController.viewModel.shouldScreenRotate = false
        
        newsController.viewModel.coordinator?.coordinate(to: .detail)
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension NewsCollectionViewDataSource {
    func dataSourceDidChange() {
        guard let collectionView = viewModel.coordinator?.viewController?.collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
