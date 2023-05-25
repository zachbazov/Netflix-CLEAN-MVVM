//
//  MediaHybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - MediaHybridCell Type

final class MediaHybridCell<Cell>: HybridCell<Cell, MediaCollectionViewDataSource<Cell>, MediaHybridCellViewModel, HomeViewModel> where Cell: UICollectionViewCell {
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createDataSource()
        createLayout()
    }
    
    override func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    override func viewWillDeallocate() {
        collectionView.removeFromSuperview()
        
        dataSource = nil
        layout = nil
        viewModel = nil
        controllerViewModel = nil
        
        removeFromSuperview()
    }
    
    override func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(Cell.self)
        return collectionView
    }
    
    override func createDataSource() {
        guard let viewModel = viewModel,
              let controllerViewModel = controllerViewModel
        else { return }
        
        dataSource = MediaCollectionViewDataSource<Cell>(on: collectionView, section: viewModel.section, viewModel: controllerViewModel)
    }
    
    override func createLayout() {
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
