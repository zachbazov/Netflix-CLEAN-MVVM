//
//  CollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/05/2023.
//

import UIKit

// MARK: - CollectionViewDataSourceProtocol Type

protocol CollectionViewDataSourceProtocol {
    associatedtype VM: ViewModel
    associatedtype Cell: CollectionViewCell<VM>
    
    func numberOfSections() -> Int
    func numberOfItems() -> Int
    func cellForItem(in collectionView: UICollectionView, at indexPath: IndexPath) -> Cell
    func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath)
    func willDisplayCellForItem(_ cell: Cell, at indexPath: IndexPath)
    func viewForSupplementaryElement(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> CollectionReusableView
}

// MARK: - CollectionViewDataSource Type

class CollectionViewDataSource<Cell, VM>: NSObject,
                                          UICollectionViewDelegate,
                                          UICollectionViewDataSource,
                                          CollectionViewDataSourceProtocol where Cell: CollectionViewCell<VM>, VM: ViewModel {
    // MARK:  UICollectionViewDelegate & UICollectionViewDataSource Implementation
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItem(in: collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem(in: collectionView, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplayCellForItem(cell as! Cell, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return viewForSupplementaryElement(in: collectionView, of: kind, at: indexPath)
    }
    
    // MARK: CollectionViewDataSourceProtocol Implementation
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems() -> Int {
        return .zero
    }
    
    func cellForItem(in collectionView: UICollectionView, at indexPath: IndexPath) -> Cell {
        return Cell()
    }
    
    func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {}
    
    func willDisplayCellForItem(_ cell: Cell, at indexPath: IndexPath) {}
    
    func viewForSupplementaryElement(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> CollectionReusableView {
        return CollectionReusableView()
    }
}
