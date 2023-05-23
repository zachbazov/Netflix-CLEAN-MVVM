//
//  DetailCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    associatedtype T
    
    var viewModel: DetailViewModel { get }
    var numberOfSections: Int { get }
    var collectionView: UICollectionView { get }
    var items: [T] { get }
}

// MARK: - DetailCollectionViewDataSource Type

final class DetailCollectionViewDataSource<T>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    fileprivate let viewModel: DetailViewModel
    fileprivate let numberOfSections = 1
    fileprivate let collectionView: UICollectionView
    
    let items: [T]
    
    /// Create a generic detail collection view data source object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - items: Represented data.
    ///   - viewModel: Coordinating view model.
    init(collectionView: UICollectionView, items: [T], with viewModel: DetailViewModel) {
        self.viewModel = viewModel
        self.collectionView = collectionView
        self.items = items
    }
    
    // MARK: UICollectionViewDelegate & UICollectionViewDataSource Implementation
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
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
                                                    reuseIdentifier: nil,
                                                    section: nil,
                                                    for: indexPath,
                                                    with: viewModel)
        case .trailers:
            return TrailerCollectionViewCell.create(of: TrailerCollectionViewCell.self,
                                                    on: collectionView,
                                                    reuseIdentifier: nil,
                                                    section: nil,
                                                    for: indexPath,
                                                    with: viewModel)
        case .similarContent:
            return PosterCollectionViewCell.create(of: PosterCollectionViewCell.self,
                                                   on: collectionView,
                                                   reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
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
