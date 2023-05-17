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
              let ds = viewModel.coordinator?.viewController?.dataSource,
              let state = ds.navigationCell?.navigationView?.viewModel.state.value
        else { fatalError() }
        if case .episodes = state {
            return EpisodeCollectionViewCell.create(on: collectionView, for: indexPath, with: viewModel)
        } else if case .trailers = state {
            return TrailerCollectionViewCell.create(on: collectionView, for: indexPath, with: viewModel)
        } else {
            return CollectionViewCell.create(on: collectionView,
                                             reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
                                             section: viewModel.section,
                                             for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel.coordinator?.viewController?.viewModel,
              let ds = viewModel.coordinator?.viewController?.dataSource,
              let state = ds.navigationCell?.navigationView?.viewModel.state.value
        else { return }
        let coordinator = viewModel.coordinator!
        if case .episodes = state {
            ///
        } else if case .trailers = state {
            ///
        } else {
            let media = items[indexPath.row] as! Media
            coordinator.viewController?.viewModel.media = media
            coordinator.coordinate(to: .detail)
        }
    }
}

// MARK: - DataSourceProtocol Implementation

extension DetailCollectionViewDataSource: DataSourceProtocol {}
