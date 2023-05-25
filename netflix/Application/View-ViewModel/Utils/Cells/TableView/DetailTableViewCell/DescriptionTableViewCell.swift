//
//  DescriptionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DescriptionTableViewCell Type

final class DescriptionTableViewCell: DetailTableViewCell {
    
    private var descriptionView: DescriptionView?
    
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
    }
}

// MARK: - Private Implementation

extension DescriptionTableViewCell {
    private func createDescription() {
        let viewModel = DescriptionViewViewModel(with: viewModel.media)
        
        descriptionView = DescriptionView(on: contentView, with: viewModel)
    }
}
