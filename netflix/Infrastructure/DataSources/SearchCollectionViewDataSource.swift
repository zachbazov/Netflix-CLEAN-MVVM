//
//  SearchCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceOutput {
    var viewModel: SearchViewModel { get }
}

private typealias DataSourceProtocol = DataSourceOutput

// MARK: - SearchCollectionViewDataSource Type

final class SearchCollectionViewDataSource: NSObject {
    fileprivate let viewModel: SearchViewModel
    /// Create a search collection view data source object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - DataSourceProtocol Implementation

extension SearchCollectionViewDataSource: DataSourceProtocol {}

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
        let navigation = Application.app.coordinator.tabCoordinator.home!
        let controller = navigation.viewControllers.first! as! HomeViewController
        let coordinator = controller.viewModel.coordinator!
        let section = controller.viewModel.section(at: .resumable)
        let cellViewModel = viewModel.items.value[row]
        coordinator.section = section
        coordinator.media = cellViewModel.media
        coordinator.shouldScreenRotate = false
        coordinator.coordinate(to: .detail)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return CollectionViewHeaderView.create(in: collectionView, at: indexPath)
        default: return .init()
        }
    }
}

// MARK: - UIScrollViewDelegate Implementation

extension SearchCollectionViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let searchViewController = viewModel.coordinator?.viewController,
              let textField = searchViewController.searchBar.searchTextField as UITextField?,
              textField.isFirstResponder else { return }
        textField.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Implementation

extension SearchCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32.0)
    }
}
