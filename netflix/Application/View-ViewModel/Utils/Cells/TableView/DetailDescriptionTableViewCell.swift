//
//  DetailDescriptionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailDescriptionTableViewCell Type

final class DetailDescriptionTableViewCell: TableViewCell<DetailViewModel> {
    private var descriptionView: DetailDescriptionView?
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createDescription()
    }
    
    override func viewHierarchyWillConfigure() {
        descriptionView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillDeallocate() {
        descriptionView?.removeFromSuperview()
        descriptionView = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - Private Presentation Logic

extension DetailDescriptionTableViewCell {
    private func createDescription() {
        let viewModel = DetailDescriptionViewViewModel(with: viewModel.media)
        
        descriptionView = DetailDescriptionView(on: contentView, with: viewModel)
    }
}
