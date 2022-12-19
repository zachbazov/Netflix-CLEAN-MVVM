//
//  SearchCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import UIKit.UICollectionView

final class SearchCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private let viewModel: SearchViewModel
    private var results: [Media] = []
    
    init(with viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let navi = Application.current.rootCoordinator.tabCoordinator.viewController?.viewControllers?.first! as! UINavigationController
        let home = navi.viewControllers.first! as! HomeViewController
        results += [viewModel.items.value[indexPath.row].toMedia()]
        return StandardCollectionViewCell.create(on: collectionView,
                                                 reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
                                                 media: results,
                                                 for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let navi = Application.current.rootCoordinator.tabCoordinator.viewController?.viewControllers?.first! as! UINavigationController
        let home = navi.viewControllers.first! as! HomeViewController
        let coordinator = home.viewModel.coordinator!
        let section = home.viewModel.section(at: .resumable)
        let media = results[indexPath.row]
        coordinator.presentMediaDetails(in: section, for: media, shouldScreenRoatate: false)
    }
}
