//
//  DetailNavigationTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var navigationView: DetailNavigationView? { get }
}

// MARK: - DetailNavigationTableViewCell Type

final class DetailNavigationTableViewCell: TableViewCell<DetailViewModel> {
    fileprivate(set) var navigationView: DetailNavigationView?
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createNavigation()
    }
    
    override func viewHierarchyWillConfigure() {
        navigationView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillDeallocate() {
        navigationView?.removeFromSuperview()
        navigationView = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension DetailNavigationTableViewCell: ViewProtocol {}

// MARK: - Private Presentation Implementation

extension DetailNavigationTableViewCell {
    private func createNavigation() {
        navigationView = DetailNavigationView(with: viewModel)
    }
}
