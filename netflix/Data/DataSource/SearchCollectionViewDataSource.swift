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
        let navi = Application.current.rootCoordinator.tabCoordinator.viewController?.viewControllers?.first! as! UINavigationController
        let home = navi.viewControllers.first! as! HomeViewController
        let media = home.viewModel.media.first { media in
            media.title == viewModel.items.value[indexPath.row].title
        }
        return StandardCollectionViewCell.create(on: collectionView,
                                                 reuseIdentifier: StandardCollectionViewCell.reuseIdentifier,
                                                 section: Section(id: -1, title: "", media: [media!]),
                                                 for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let navi = Application.current.rootCoordinator.tabCoordinator.viewController?.viewControllers?.first! as! UINavigationController
        let home = navi.viewControllers.first! as! HomeViewController
        let coordinator = home.viewModel.coordinator!
        let section = home.viewModel.section(at: .resumable)
        let media = home.viewModel.media.first { media in
            media.title == viewModel.items.value[indexPath.row].title
        }
        coordinator.presentMediaDetails(in: section, for: media!, shouldScreenRoatate: false)
    }
}
