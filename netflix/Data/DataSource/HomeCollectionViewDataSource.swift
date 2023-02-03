//
//  HomeCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - HomeCollectionViewDataSource Type

final class HomeCollectionViewDataSource<Cell>: NSObject,
                                                UICollectionViewDelegate,
                                                UICollectionViewDataSource,
                                                UICollectionViewDataSourcePrefetching where Cell: UICollectionViewCell {
    private weak var coordinator: HomeViewCoordinator!
    private weak var collectionView: UICollectionView!
    private let section: Section
    /// Create home's collection view data source object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - section: Corresponding media's section object.
    ///   - viewModel: Coordinating view model.
    init(on collectionView: UICollectionView,
         section: Section,
         viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator
        self.section = section
        self.collectionView = collectionView
        super.init()
        self.viewDidLoad()
    }
    
    deinit {
        collectionView = nil
        coordinator = nil
    }
    
    // MARK: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDataSourcePrefetching Implementation
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CollectionViewCell.create(on: collectionView,
                                         reuseIdentifier: Cell.reuseIdentifier,
                                         section: section,
                                         for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = section.media[indexPath.row]
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = false
        coordinator.showScreen(.detail)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {}
}

// MARK: - UI Setup

extension HomeCollectionViewDataSource {
    private func viewDidLoad() {
        dataSourceDidChange()
    }
    
    private func dataSourceDidChange() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.reloadData()
    }
}
