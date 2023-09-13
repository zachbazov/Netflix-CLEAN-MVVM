//
//  InfoTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - InfoTableViewCell Type

final class InfoTableViewCell: DetailTableViewCell {
    private(set) var infoView: InfoView?
    
    deinit {
        viewWillDeallocate()
        super.viewWillDeallocate()
    }
    
    // MARK: TableViewCell Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createInfo()
    }
    
    func viewHierarchyWillConfigure() {
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
        let viewModel = InfoViewViewModel(with: self.viewModel)
        
        infoView = InfoView(on: contentView, with: viewModel)
    }
}
