//
//  SearchCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit

// MARK: - SearchCollectionViewDataSource Type

final class SearchCollectionViewDataSource: CollectionViewDataSource {
    fileprivate let viewModel: SearchViewModel
    
    fileprivate(set) var headerView: LabeledCollectionHeaderView?
    
    init(with viewModel: SearchViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func numberOfItems(in section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T : UICollectionViewCell {
        return SearchCollectionViewCell.create(of: SearchCollectionViewCell.self,
                                               on: collectionView,
                                               for: indexPath,
                                               with: viewModel) as! T
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let controller = Application.app.coordinator.tabCoordinator?.home?.viewControllers.first as? HomeViewController,
              let homeViewModel = controller.viewModel,
              let coordinator = homeViewModel.coordinator
        else { return }
        
        guard let row = indexPath.row as Int?, row >= 0, row <= viewModel.items.value.count - 1 else { return }
        
        let cellViewModel = viewModel.items.value[row]
        
        guard let media = cellViewModel.media else { return }
        
        let section = controller.navigationOverlay?.viewModel?.category.toSection()
        let rotated = false
        
        coordinator.coordinate(to: .detail)
        
        guard let detailController = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        detailController.viewModel.media = media
        detailController.viewModel.section = section
        detailController.viewModel.isRotated = rotated
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
    
    override func viewForSupplementaryElement(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            headerView = LabeledCollectionHeaderView.create(in: collectionView, at: indexPath)
            
            guard let headerView = headerView else { fatalError() }
            
            return headerView
        default: return UICollectionReusableView()
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
