//
//  SearchCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit.UICollectionView

final class SearchCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private let viewModel: SearchViewModel
    
    init(with viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return SearchCollectionViewCell.create(on: collectionView, for: indexPath, with: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let navigation = Application.current.rootCoordinator.tabCoordinator.viewController?.viewControllers?.first! as! UINavigationController
        let controller = navigation.viewControllers.first! as! HomeViewController
        let coordinator = controller.viewModel.coordinator!
        let section = controller.viewModel.section(at: .resumable)
        let media = viewModel.items.value[indexPath.row].toMedia()
        coordinator.presentMediaDetails(in: section, for: media, shouldScreenRotate: false)
    }
}
