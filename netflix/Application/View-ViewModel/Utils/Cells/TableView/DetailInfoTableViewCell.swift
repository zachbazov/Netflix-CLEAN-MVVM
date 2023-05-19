//
//  DetailInfoTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailInfoTableViewCell Type

final class DetailInfoTableViewCell: TableViewCell<DetailViewModel> {
    private var infoView: DetailInfoView?
    
    deinit {
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createInfo()
    }
    
    override func viewHierarchyWillConfigure() {
        infoView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.black)
        selectionStyle = .none
    }
    
    override func viewWillDeallocate() {
        infoView?.removeFromSuperview()
        infoView = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - Private Presentation Implementation

extension DetailInfoTableViewCell {
    private func createInfo() {
        let viewModel = DetailInfoViewViewModel(with: viewModel)
        
        infoView = DetailInfoView(on: contentView, with: viewModel)
    }
}
