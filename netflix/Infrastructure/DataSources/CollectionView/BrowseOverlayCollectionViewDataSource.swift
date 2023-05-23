//
//  BrowseOverlayCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: BrowseOverlayViewModel { get }
}

// MARK: - BrowseOverlayCollectionViewDataSource Type

final class BrowseOverlayCollectionViewDataSource: NSObject {
    fileprivate let viewModel: BrowseOverlayViewModel
    
    init(viewModel: BrowseOverlayViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - DataSourceProtocol Implementation

extension BrowseOverlayCollectionViewDataSource: DataSourceProtocol {}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource Implementation

extension BrowseOverlayCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.section.value.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return PosterCollectionViewCell.create(of: PosterCollectionViewCell.self,
                                               on: collectionView,
                                               reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
                                               section: viewModel.section.value,
                                               for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelect(at: indexPath)
    }
}
