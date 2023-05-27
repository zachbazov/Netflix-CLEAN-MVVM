//
//  InfoTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - InfoTableViewCell Type

final class InfoTableViewCell: DetailTableViewCell {
    
    private var infoView: InfoView?
    
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
        createInfo()
    }
    
    override func viewHierarchyWillConfigure() {
        infoView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillDeallocate() {
        infoView?.removeFromSuperview()
        infoView = nil
    }
}

// MARK: - Private Implementation

extension InfoTableViewCell {
    private func createInfo() {
        let viewModel = InfoViewViewModel(with: viewModel)
        
        infoView = InfoView(on: contentView, with: viewModel)
    }
}
