//
//  ShowcaseTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ShowcaseTableViewCell Type

final class ShowcaseTableViewCell: UITableViewCell {
    var viewModel: ShowcaseTableViewCellViewModel!
    
    fileprivate(set) var showcaseView: ShowcaseView?
    
    deinit {
        viewWillDeallocate()
    }
    
    override func prepareForReuse() {
        showcaseView?.viewWillDeallocate()
        
        super.prepareForReuse()
        
        showcaseView?.setDarkBottomGradient()
    }
}

// MARK: - TableViewCell Implementation

extension ShowcaseTableViewCell: TableViewCell {
    func viewDidLoad() {
        viewWillConfigure()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createShowcaseView()
    }
    
    func viewHierarchyWillConfigure() {
        showcaseView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    func viewWillDeallocate() {
        showcaseView?.viewWillDeallocate()
        showcaseView = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - Private Implementation

extension ShowcaseTableViewCell {
    private func createShowcaseView() {
        showcaseView = ShowcaseView(with: viewModel)
    }
}
