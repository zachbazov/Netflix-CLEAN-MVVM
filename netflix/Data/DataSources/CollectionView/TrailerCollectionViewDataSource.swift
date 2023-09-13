//
//  TrailerCollectionViewDataSource.swift
//  netflix
//
//  Created by Developer on 12/09/2023.
//

import UIKit

// MARK: - TrailerCollectionViewDataSource Type

final class TrailerCollectionViewDataSource: CollectionViewDataSource {
    private let viewModel: MyNetflixViewModel
    private weak var collectionView: UICollectionView?
    
    private var section: Section {
        guard let items = viewModel.menuItems[4].items else { return .vacantValue }
        
        return Section(id: 23, title: "Trailers Watched", media: items)
    }
    
    init(collectionView: UICollectionView, with viewModel: MyNetflixViewModel) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        guard let items = viewModel.menuItems[4].items else { return .zero }
        return items.count
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return MediaCollectionViewCell.create(of: StandardCollectionViewCell.self,
                                              on: collectionView,
                                              section: section,
                                              for: indexPath,
                                              with: viewModel) as! T
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        guard let coordinator = viewModel.coordinator,
              let items = viewModel.menuItems[4].items
        else { return }
        
        coordinator.coordinate(to: .detail)
        
        guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
        
        let section = Section(id: 24, title: "Trailers Watched - Similar Content", media: items)
        let item = items[indexPath.row]
        
        controller.viewModel.section = section
        controller.viewModel.media = item
        controller.viewModel.isRotated = false
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension TrailerCollectionViewDataSource {
    func dataSourceDidChange() {
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
