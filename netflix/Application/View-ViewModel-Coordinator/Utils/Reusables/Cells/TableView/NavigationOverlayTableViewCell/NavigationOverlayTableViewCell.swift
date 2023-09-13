//
//  NavigationOverlayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - NavigationOverlayTableViewCell Type

final class NavigationOverlayTableViewCell: UITableViewCell, TableViewCell {
    fileprivate lazy var titleLabel = createLabel()
    
    var viewModel: NavigationOverlayCollectionViewCellViewModel!
    
    func viewDidLoad() {
        viewDidDeploySubviews()
        viewDidConfigure()
    }
    
    func viewDidConfigure() {
        titleLabel.text = viewModel.title
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension NavigationOverlayTableViewCell: ViewLifecycleBehavior {
    func viewDidDeploySubviews() {
        backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: - Private Implementation

extension NavigationOverlayTableViewCell {
    private func createLabel() -> UILabel {
        let label = UILabel(frame: .init(x: 24.0, y: .zero, width: bounds.width, height: 44.0))
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        addSubview(label)
        return label
    }
}
