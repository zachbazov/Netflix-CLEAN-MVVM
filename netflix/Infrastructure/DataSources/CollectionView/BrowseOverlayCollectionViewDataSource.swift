//
//  BrowseOverlayCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var coordinator: HomeViewCoordinator { get }
    var section: Section? { get }
}

// MARK: - BrowseOverlayCollectionViewDataSource Type

final class BrowseOverlayCollectionViewDataSource: NSObject {
    fileprivate let coordinator: HomeViewCoordinator
    
    var section: Section?
    
    /// Create a browse overlay collection view data source object.
    /// - Parameters:
    ///   - section: Corresponding media's section object.
    ///   - viewModel: Coordinating view model.
    init(section: Section? = nil, with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.section = section
    }
}

// MARK: - DataSourceProtocol Implementation

extension BrowseOverlayCollectionViewDataSource: DataSourceProtocol {}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource Implementation

extension BrowseOverlayCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let s = self.section else { return .zero }
        return s.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return StandardCollectionViewCell.create(
            on: collectionView,
            reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
            section: section,
            for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let homeViewModel = coordinator.viewController?.viewModel,
              let section = section
        else { return }
        
        let media = section.media[indexPath.row]
        
        homeViewModel.detailSection = section
        homeViewModel.detailMedia = media
        homeViewModel.shouldScreenRotate = false
        
        coordinator.coordinate(to: .detail)
    }
}
