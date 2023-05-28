//
//  CollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/05/2023.
//

import UIKit

// MARK: - CollectionViewDataSourceProtocol Type

private protocol CollectionViewDataSourceProtocol {
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell
    func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath)
    func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell
    func viewForSupplementaryElement(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView
}

// MARK: - CollectionViewDataSource Type

class CollectionViewDataSource: NSObject,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                CollectionViewDataSourceProtocol {
    
    // MARK:  UICollectionViewDelegate & UICollectionViewDataSource Implementation
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItem(in: collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        didSelectItem(in: collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        willDisplayCellForItem(cell, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return viewForSupplementaryElement(in: collectionView, of: kind, at: indexPath)
    }
    
    // MARK: CollectionViewDataSourceProtocol Implementation
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return .zero
    }
    
    func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return T()
    }
    
    func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {}
    
    func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {}
    
    func viewForSupplementaryElement(in collectionView: UICollectionView,
                                     of kind: String,
                                     at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}
