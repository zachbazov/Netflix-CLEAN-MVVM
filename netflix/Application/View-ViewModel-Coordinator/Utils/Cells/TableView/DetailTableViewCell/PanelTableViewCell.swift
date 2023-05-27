//
//  PanelTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - PanelTableViewCell Type

final class PanelTableViewCell: DetailTableViewCell {
    
    private var panelView: DetailPanelView?
    
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
        createPanelView()
    }
    
    override func viewHierarchyWillConfigure() {
        panelView?.addToHierarchy(on: contentView)
    }
    
    override func viewWillDeallocate() {
        panelView?.removeFromSuperview()
        panelView = nil
    }
}

// MARK: - Private Logic

extension PanelTableViewCell {
    private func createPanelView() {
        panelView = DetailPanelView(on: contentView, with: viewModel)
    }
}
