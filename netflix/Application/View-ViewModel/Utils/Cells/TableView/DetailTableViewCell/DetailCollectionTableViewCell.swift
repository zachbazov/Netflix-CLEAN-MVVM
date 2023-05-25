//
//  DetailCollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailCollectionTableViewCell Type

final class DetailCollectionTableViewCell: DetailTableViewCell {
    
    private(set) var detailCollectionView: DetailCollectionView?
    
    deinit {
        viewWillDeallocate()
        super.viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createCollection()
    }
    
    override func viewHierarchyWillConfigure() {
        detailCollectionView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillDeallocate() {
        detailCollectionView?.removeFromSuperview()
        detailCollectionView = nil
        
        removeFromSuperview()
    }
}

// MARK: - Private Implementation

extension DetailCollectionTableViewCell {
    private func createCollection() {
        detailCollectionView = DetailCollectionView(with: viewModel)
    }
}
