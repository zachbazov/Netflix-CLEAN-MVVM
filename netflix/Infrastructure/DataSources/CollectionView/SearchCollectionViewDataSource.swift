//
//  SearchCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var viewModel: SearchViewModel { get }
    var headerView: LabeledCollectionHeaderView? { get }
}

// MARK: - SearchCollectionViewDataSource Type

final class SearchCollectionViewDataSource: CollectionViewDataSource<SearchCollectionViewCell, SearchCollectionViewCellViewModel> {
    fileprivate let viewModel: SearchViewModel
    
    fileprivate(set) var headerView: LabeledCollectionHeaderView?
    
    init(with viewModel: SearchViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func numberOfItems() -> Int {
        return viewModel.items.value.count
    }
    
    override func cellForItem(in collectionView: UICollectionView, at indexPath: IndexPath) -> SearchCollectionViewCell {
        return SearchCollectionViewCell.create(of: SearchCollectionViewCell.self,
                                               on: collectionView,
                                               reuseIdentifier: nil,
                                               section: nil,
                                               for: indexPath,
                                               with: viewModel)
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let controller = Application.app.coordinator.tabCoordinator.viewController?.homeViewController,
              let homeViewModel = controller.viewModel,
              let coordinator = homeViewModel.coordinator
        else { return }
        
        guard let row = indexPath.row as Int?, row >= 0, row <= viewModel.items.value.count - 1 else { return }
        
        let cellViewModel = viewModel.items.value[row]
        
        guard let media = cellViewModel.media else { return }
        
        let section = controller.navigationOverlay?.viewModel?.category.toSection()
        let rotated = false
        
        coordinator.coordinate(to: .detail)
        
        guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        controller.viewModel.media = media
        controller.viewModel.section = section
        controller.viewModel.isRotated = rotated
    }
    
    override func willDisplayCellForItem(_ cell: SearchCollectionViewCell, at indexPath: IndexPath) {
        cell.opacityAnimation()
    }
    
    override func viewForSupplementaryElement(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> CollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            headerView = LabeledCollectionHeaderView.create(in: collectionView, at: indexPath)
            return headerView!
        default: return .init()
        }
    }
}

// MARK: - DataSourceProtocol Implementation

extension SearchCollectionViewDataSource: DataSourceProtocol {}

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
