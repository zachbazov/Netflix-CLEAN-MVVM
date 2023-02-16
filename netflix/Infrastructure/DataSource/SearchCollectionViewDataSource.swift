//
//  SearchCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit.UICollectionView

// MARK: - SearchCollectionViewDataSource Type

final class SearchCollectionViewDataSource: NSObject {
    private let viewModel: SearchViewModel
    /// Create a search collection view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource Implementation

extension SearchCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return SearchCollectionViewCell.create(on: collectionView, for: indexPath, with: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let row = indexPath.row as Int?, row >= 0, row <= viewModel.items.value.count - 1 else { return }
        let navigation = Application.app.sceneCoordinator.tabCoordinator.home!
        let controller = navigation.viewControllers.first! as! HomeViewController
        let coordinator = controller.viewModel.coordinator!
        let section = controller.viewModel.section(at: .resumable)
        let cellViewModel = viewModel.items.value[row]
        coordinator.section = section
        coordinator.media = cellViewModel.media
        coordinator.shouldScreenRotate = false
        coordinator.coordinate(to: .detail)
    }
}
