//
//  HybridCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - HybridCell Type

final class HybridCell<Cell>:
    CollectionTableViewCell<Cell, HomeCollectionViewDataSource<Cell>, CollectionTableViewCellViewModel, HomeViewModel>
where Cell: UICollectionViewCell {
    
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
    
    override func createDataSource() {
        guard let viewModel = viewModel,
              let controllerViewModel = controllerViewModel
        else { return }
        
        dataSource = HomeCollectionViewDataSource<Cell>(on: collectionView, section: viewModel.section, viewModel: controllerViewModel)
    }
    
    override func createLayout() {
        guard let viewModel = viewModel,
              let indices = HomeTableViewDataSource.Index(rawValue: viewModel.section.id)
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

extension HybridCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}
