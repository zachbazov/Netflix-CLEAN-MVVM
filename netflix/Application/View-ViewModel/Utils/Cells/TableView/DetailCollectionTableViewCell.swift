//
//  DetailCollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var detailCollectionView: DetailCollectionView? { get }
}

// MARK: - DetailCollectionTableViewCell Type

final class DetailCollectionTableViewCell: TableViewCell<DetailViewModel> {
    private(set) var detailCollectionView: DetailCollectionView?
    
    override func viewDidLoad() {
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
}

// MARK: - ViewProtocol Implementation

extension DetailCollectionTableViewCell: ViewProtocol {}

// MARK: - Private Presentation Implementation

extension DetailCollectionTableViewCell {
    private func createCollection() {
        detailCollectionView = DetailCollectionView(with: viewModel)
    }
}
