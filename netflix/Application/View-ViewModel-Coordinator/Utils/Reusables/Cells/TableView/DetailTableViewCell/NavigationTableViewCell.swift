//
//  NavigationTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - NavigationTableViewCell Type

final class NavigationTableViewCell: DetailTableViewCell {
    fileprivate(set) var navigationView: DetailNavigationView?
    
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
        createNavigation()
    }
    
    func viewHierarchyWillConfigure() {
        navigationView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillDeallocate() {
        navigationView?.removeFromSuperview()
        navigationView = nil
    }
}

// MARK: - Private Implementation

extension NavigationTableViewCell {
    private func createNavigation() {
        navigationView = DetailNavigationView(with: viewModel)
    }
}
