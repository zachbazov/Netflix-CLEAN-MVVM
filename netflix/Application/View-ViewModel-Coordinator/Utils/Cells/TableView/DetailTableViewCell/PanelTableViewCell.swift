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
    
    // MARK: TableViewCell Implementation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createPanelView()
    }
    
    func viewHierarchyWillConfigure() {
        panelView?.addToHierarchy(on: contentView)
    }
    
    override func viewWillDeallocate() {
        panelView?.removeFromSuperview()
        panelView = nil
    }
}

// MARK: - Private Implementation

extension PanelTableViewCell {
    private func createPanelView() {
        panelView = DetailPanelView(on: contentView, with: viewModel)
    }
}
