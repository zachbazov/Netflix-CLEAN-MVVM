//
//  LabeledCollectionHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 03/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var titleLabel: UILabel { get }
}

// MARK: - LabeledCollectionHeaderView Type

final class LabeledCollectionHeaderView: CollectionReusableView {
    fileprivate(set) lazy var titleLabel: UILabel = createTitleLabel()
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
    }
    
    override func viewHierarchyWillConfigure() {
        titleLabel
            .addToHierarchy(on: self)
            .constraintBottom(toParent: self, withBottomAnchor: -8.0)
    }
}

// MARK: - ViewProtocol Implementation

extension LabeledCollectionHeaderView: ViewProtocol {}

// MARK: - Private Presentation Implementation

extension LabeledCollectionHeaderView {
    private func createTitleLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Searches"
        label.font = .systemFont(ofSize: 18.0, weight: .bold)
        label.textColor = .white
        return label
    }
}
