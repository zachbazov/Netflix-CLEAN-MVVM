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

final class DetailCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    // MARK: UICollectionViewDelegate & UICollectionViewDataSource Implementation
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel.coordinator?.viewController?.viewModel,
              let dataSource = viewModel.coordinator?.viewController?.dataSource,
              let state = dataSource.navigationCell?.navigationView?.viewModel.state.value
        else { fatalError() }
        
        switch state {
        case .episodes:
            return EpisodeCollectionViewCell.create(of: EpisodeCollectionViewCell.self,
                                                    on: collectionView,
                                                    for: indexPath,
                                                    with: viewModel)
        case .trailers:
            return TrailerCollectionViewCell.create(of: TrailerCollectionViewCell.self,
                                                    on: collectionView,
                                                    for: indexPath,
                                                    with: viewModel)
        case .similarContent:
            return MediaCollectionViewCell.create(of: StandardCollectionViewCell.self,
                                                   on: collectionView,
                                                   section: viewModel.section,
                                                   for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
}

// MARK: - DataSourceProtocol Implementation

extension DetailCollectionViewDataSource: DataSourceProtocol {}
