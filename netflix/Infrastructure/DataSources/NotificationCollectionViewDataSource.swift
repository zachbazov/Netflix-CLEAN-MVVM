//
//  NotificationCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 12/03/2023.
//

import UIKit

final class NotificationCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private weak var collectionView: UICollectionView?
    private let viewModel: AccountViewModel
    
    init(collectionView: UICollectionView, with viewModel: AccountViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.menuItems[section].options?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = NotificationCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel)
        print(cell.bounds)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(viewModel.menuItems[indexPath.section].options?[indexPath.row].title)
    }
}
