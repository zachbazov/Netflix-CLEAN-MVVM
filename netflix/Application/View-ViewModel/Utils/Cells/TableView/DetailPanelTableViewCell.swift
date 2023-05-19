//
//  DetailPanelTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailPanelTableViewCell Type

final class DetailPanelTableViewCell: TableViewCell<DetailViewModel> {
    private var panelView: DetailPanelView?
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    override func viewWillDeploySubviews() {
        createPanelView()
    }
    
    override func viewHierarchyWillConfigure() {
        panelView?.addToHierarchy(on: contentView)
    }
    
    override func viewWillDeallocate() {
        panelView?.removeFromSuperview()
        panelView = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - Private Presentation Logic

extension DetailPanelTableViewCell {
    private func createPanelView() {
        panelView = DetailPanelView(on: contentView, with: viewModel)
    }
}
