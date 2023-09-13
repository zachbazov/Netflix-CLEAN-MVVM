//
//  LabeledTableHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - LabeledTableHeaderView Type

final class LabeledTableHeaderView: UITableViewHeaderFooterView {
    fileprivate lazy var titleLabel: UILabel = createLabel()
    
    var viewModel: LabeledTableHeaderViewModel!
    
    deinit {
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - TableViewHeader Implementation

extension LabeledTableHeaderView: TableViewHeader {
    func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    func viewHierarchyWillConfigure() {
        titleLabel
            .addToHierarchy(on: contentView)
            .constraintBottom(toParent: contentView, withLeadingAnchor: .zero)
        
        backgroundView?
            .constraintToSuperview(contentView)
    }
    
    func viewWillConfigure() {
        configureBackground()
        configureTitle()
    }
    
    func setTitle(_ string: String) {
        titleLabel.text = string
    }
}

// MARK: - Private Implementation

extension LabeledTableHeaderView {
    private func createLabel() -> UILabel {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.font = font
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }
    
    private func configureBackground() {
        backgroundView = UIView()
        backgroundView?.setBackgroundColor(.clear)
    }
    
    private func configureTitle() {
        setTitle(viewModel.title)
    }
}
