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
    var section: Section { get }
    var items: [Media] { get }
}

// MARK: - BrowseOverlayCollectionViewDataSource Type

final class BrowseOverlayCollectionViewDataSource: NSObject {
    fileprivate let coordinator: HomeViewCoordinator
    fileprivate let section: Section
    fileprivate let items: [Media]
    /// Create a browse overlay collection view data source object.
    /// - Parameters:
    ///   - section: Corresponding media's section object.
    ///   - viewModel: Coordinating view model.
    init(section: Section, with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
        self.section = section
        self.items = section.media
    }
}

// MARK: - DataSourceProtocol Implementation

extension BrowseOverlayCollectionViewDataSource: DataSourceProtocol {}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource Implementation

extension BrowseOverlayCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return StandardCollectionViewCell.create(
            on: collectionView,
            reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
            section: section,
            for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = items[indexPath.row]
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = false
        coordinator.coordinate(to: .detail)
    }
}
