//
//  DetailCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: DetailViewModel { get }
    var items: [Mediable] { get }
}

// MARK: - DetailCollectionViewDataSource Type

final class DetailCollectionViewDataSource: CollectionViewDataSource {
    
    fileprivate let viewModel: DetailViewModel
    
    let items: [Mediable]
    
    /// Create a generic detail collection view data source object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - items: Represented data.
    ///   - viewModel: Coordinating view model.
    init(items: [Mediable], with viewModel: DetailViewModel) {
        self.viewModel = viewModel
        self.items = items
    }
    
    // MARK: CollectionViewDataSourceProtocol Implementation
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return items.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        guard let viewModel = viewModel.coordinator?.viewController?.viewModel,
              let dataSource = viewModel.coordinator?.viewController?.dataSource,
              let state = dataSource.navigationCell?.navigationView?.viewModel.state.value
        else { fatalError() }
        
        switch state {
        case .episodes:
            return DetailCollectionViewCell.create(of: EpisodeCollectionViewCell.self,
                                                   on: collectionView,
                                                   for: indexPath,
                                                   with: viewModel) as! T
        case .trailers:
            return DetailCollectionViewCell.create(of: TrailerCollectionViewCell.self,
                                                    on: collectionView,
                                                    for: indexPath,
                                                    with: viewModel) as! T
        case .similarContent:
            return MediaCollectionViewCell.create(of: StandardCollectionViewCell.self,
                                                   on: collectionView,
                                                   section: viewModel.section,
                                                   for: indexPath) as! T
        }
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let coordinator = viewModel.coordinator,
              let viewModel = viewModel.coordinator?.viewController?.viewModel,
              let dataSource = viewModel.coordinator?.viewController?.dataSource,
              let state = dataSource.navigationCell?.navigationView?.viewModel.state.value
        else { fatalError() }
        
        switch state {
        case .episodes:
            break
        case .trailers:
            break
        case .similarContent:
            guard let media = items[indexPath.row] as? Media else { return }
            
            viewModel.media = media
            
            coordinator.coordinate(to: .detail)
        }
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - DataSourceProtocol Implementation

extension DetailCollectionViewDataSource: DataSourceProtocol {}
