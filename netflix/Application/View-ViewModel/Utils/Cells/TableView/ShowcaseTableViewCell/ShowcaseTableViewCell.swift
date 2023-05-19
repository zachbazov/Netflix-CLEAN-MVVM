//
//  ShowcaseTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var showcaseView: ShowcaseView? { get }
}

// MARK: - ShowcaseTableViewCell Type

final class ShowcaseTableViewCell: TableViewCell<ShowcaseTableViewCellViewModel> {
    fileprivate(set) var showcaseView: ShowcaseView?
    
    deinit {
        print("deinit \(Self.self)")
        
        showcaseView?.viewWillDeallocate()
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createShowcaseView()
    }
    
    override func viewHierarchyWillConfigure() {
        showcaseView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    override func viewWillDeallocate() {
        showcaseView = nil
        viewModel = nil
        
        removeFromSuperview()
    }
    
    override func prepareForReuse() {
        showcaseView?.viewWillDeallocate()
        
        super.prepareForReuse()
        
        showcaseView?.setDarkBottomGradient()
    }
}

// MARK: - Private Presentation Implementation

extension ShowcaseTableViewCell {
    private func createShowcaseView() {
        showcaseView = ShowcaseView(on: contentView, with: viewModel)
    }
}
