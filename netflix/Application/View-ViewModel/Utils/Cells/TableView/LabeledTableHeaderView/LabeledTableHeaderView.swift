//
//  LabeledTableHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var titleLabel: UILabel { get }
    
    func setTitle(_ string: String)
}

// MARK: - LabeledTableHeaderView Type

final class LabeledTableHeaderView: TableViewHeader<LabeledTableHeaderViewModel> {
    fileprivate lazy var titleLabel: UILabel = createLabel()
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillConfigure()
    }
    
    override func viewHierarchyWillConfigure() {
        titleLabel
            .addToHierarchy(on: contentView)
            .constraintBottom(toParent: contentView, withLeadingAnchor: .zero)
        
        backgroundView?
            .constraintToSuperview(contentView)
    }
    
    override func viewWillConfigure() {
        configureBackground()
        configureTitle()
    }
}

// MARK: - ViewModelProtocol Implementation

extension LabeledTableHeaderView: ViewModelProtocol {
    fileprivate func setTitle(_ string: String) {
        titleLabel.text = string
    }
}

// MARK: - Private Presentation Implementation

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
