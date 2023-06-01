//
//  MediaHybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - MediaHybridCell Type

final class MediaHybridCell<Cell>: UITableViewCell where Cell: UICollectionViewCell {
    lazy var collectionView: UICollectionView = createCollectionView()
    var cell: Cell?
    var dataSource: MediaCollectionViewDataSource<Cell>?
    var viewModel: MediaHybridCellViewModel?
    var controllerViewModel: HomeViewModel?
    var layout: CollectionViewLayout?
    
    deinit {
        viewWillDeallocate()
    }
}

// MARK: - HybridCell Implementation

extension MediaHybridCell: HybridCell {
    func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    func viewWillDeallocate() {
        collectionView.removeFromSuperview()
        cell?.removeFromSuperview()
        
        cell = nil
        dataSource = nil
        viewModel = nil
        controllerViewModel = nil
        layout = nil
        
        removeFromSuperview()
    }
    
    func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(Cell.self)
        return collectionView
    }
    
    func createDataSource() {
        guard let viewModel = viewModel,
              let controllerViewModel = controllerViewModel
        else { return }
        
        dataSource = MediaCollectionViewDataSource<Cell>(on: collectionView, section: viewModel.section, viewModel: controllerViewModel)
    }
    
    func createLayout() {
        guard let viewModel = viewModel,
              let indices = MediaTableViewDataSource.Index(rawValue: viewModel.section.id)
        else { return }
        
        switch indices {
        case .display:
            return
        case .rated:
            layout = CollectionViewLayout(layout: .rated, scrollDirection: .horizontal)
        case .blockbuster:
            layout = CollectionViewLayout(layout: .blockbuster, scrollDirection: .horizontal)
        default:
            layout = CollectionViewLayout(layout: .standard, scrollDirection: .horizontal)
        }
        
        setLayout()
    }
}

// MARK: - SortOptions Type

extension MediaHybridCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}
