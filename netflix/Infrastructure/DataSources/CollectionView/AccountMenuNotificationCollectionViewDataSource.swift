//
//  AccountMenuNotificationCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 12/03/2023.
//

import UIKit

// MARK: - DataSourceProtocol Type

private protocol DataSourceProtocol {
    var collectionView: UICollectionView? { get }
    var numberOfSections: Int { get }
    
    func dataSourceDidChange(at indexPaths: [IndexPath])
}

// MARK: - AccountMenuNotificationCollectionViewDataSource Type

final class AccountMenuNotificationCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private let viewModel: AccountViewModel
    
    fileprivate weak var collectionView: UICollectionView?
    
    fileprivate let numberOfSections: Int = 1
    
    deinit {
        print("deinit \(String(describing: Self.self))")
    }
    
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
        return AccountMenuNotificationCollectionViewCell.create(of: AccountMenuNotificationCollectionViewCell.self,
                                                                on: collectionView,
                                                                reuseIdentifier: nil,
                                                                section: nil,
                                                                for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

// MARK: - DataSourceProtocol Implementation

extension AccountMenuNotificationCollectionViewDataSource: DataSourceProtocol {
    func dataSourceDidChange(at indexPaths: [IndexPath]) {
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadItems(at: indexPaths)
    }
}
