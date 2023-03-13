//
//  NotificationCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 12/03/2023.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceInput {
    func dataSourceDidChange(at indexPaths: [IndexPath])
}

private protocol DataSourceOutput {
    var collectionView: UICollectionView? { get }
    var numberOfSections: Int { get }
}

private typealias DataSourceProtocol = DataSourceInput

// MARK: - NotificationCollectionViewDataSource Type

final class NotificationCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private let viewModel: AccountViewModel
    
    fileprivate weak var collectionView: UICollectionView?
    
    fileprivate let numberOfSections: Int = 1
    
    init(collectionView: UICollectionView, with viewModel: AccountViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.menuItems[section].options?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return NotificationCollectionViewCell.create(in: collectionView, at: indexPath, with: viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - DataSourceProtocol Implementation

extension NotificationCollectionViewDataSource: DataSourceProtocol {
    func dataSourceDidChange(at indexPaths: [IndexPath]) {
        guard let collectionView = collectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadItems(at: indexPaths)
    }
}
