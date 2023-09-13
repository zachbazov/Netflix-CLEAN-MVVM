//
//  MyListCollectionViewDataSource.swift
//  netflix
//
//  Created by Developer on 12/09/2023.
//

import UIKit

// MARK: - MyListCollectionViewDataSource Type

final class MyListCollectionViewDataSource<T>: CollectionViewDataSource where T: ViewModel {
    private let viewModel: T
    private weak var collectionView: UICollectionView?
    
    private var section: Section {
        switch viewModel {
        case let viewModel as MyNetflixViewModel:
            guard let items = viewModel.menuItems[3].items else { return .vacantValue }
            
            return Section(id: 21, title: "My List", media: items)
        case let viewModel as MyListViewModel:
            let items = viewModel.media
            
            return Section(id: 21, title: "My List", media: items)
        default:
            return .vacantValue
        }
    }
    
    init(collectionView: UICollectionView, with viewModel: T) {
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(in section: Int) -> Int {
        switch viewModel {
        case let viewModel as MyNetflixViewModel:
            guard let items = viewModel.menuItems[3].items else { return .zero }
            
            return items.count
        case let viewModel as MyListViewModel:
            return viewModel.media.count
        default:
            return .zero
        }
    }
    
    override func cellForItem<T>(in collectionView: UICollectionView, at indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return MediaCollectionViewCell.create(of: StandardCollectionViewCell.self,
                                              on: collectionView,
                                              section: section,
                                              for: indexPath,
                                              with: viewModel) as! T
    }
    
    override func didSelectItem(in collectionView: UICollectionView, at indexPath: IndexPath) {
        switch viewModel {
        case let viewModel as MyNetflixViewModel:
            guard let coordinator = viewModel.coordinator else { return }
            
            coordinator.coordinate(to: .detail)
            
            guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController,
                  let items = viewModel.menuItems[3].items
            else { return }
            
            let section = Section(id: 22, title: "My List - Similar Content", media: items)
            let item = items[indexPath.row]
            
            controller.viewModel.section = section
            controller.viewModel.media = item
            controller.viewModel.isRotated = false
        case let viewModel as MyListViewModel:
            guard let coordinator = viewModel.coordinator else { return }
            
            coordinator.coordinate(to: .detail)
            
            guard let controller = coordinator.detail?.viewControllers.first as? DetailViewController else { return }
            
            let items = viewModel.media
            let section = Section(id: 22, title: "My List - Similar Content", media: items)
            let item = items[indexPath.row]
            
            controller.viewModel.section = section
            controller.viewModel.media = item
            controller.viewModel.isRotated = false
        default:
            return
        }
        
    }
    
    override func willDisplayCellForItem<T>(_ cell: T, at indexPath: IndexPath) where T: UICollectionViewCell {
        cell.opacityAnimation()
    }
}

// MARK: - Internal Implementation

extension MyListCollectionViewDataSource {
    func dataSourceDidChange() {
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}
