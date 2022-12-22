//
//  HomeCollectionViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

private protocol DataSourceInput {
    func viewDidLoad()
    func dataSourceDidChange()
}

private protocol DataSourceOutput {
    var collectionView: UICollectionView! { get }
    var section: Section { get }
}

private typealias DataSource = DataSourceInput & DataSourceOutput

final class HomeCollectionViewDataSource<Cell>: NSObject,
                                                DataSource,
                                                UICollectionViewDelegate,
                                                UICollectionViewDataSource,
                                                UICollectionViewDataSourcePrefetching where Cell: UICollectionViewCell {
    weak var coordinator: HomeViewCoordinator!
    weak var collectionView: UICollectionView!
    fileprivate var section: Section
    
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
    
    fileprivate func viewDidLoad() {
        dataSourceDidChange()
    }
    
    fileprivate func dataSourceDidChange() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.reloadData()
    }
    
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
