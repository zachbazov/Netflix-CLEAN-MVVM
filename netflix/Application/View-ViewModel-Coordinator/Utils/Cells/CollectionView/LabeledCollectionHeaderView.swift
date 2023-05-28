//
//  LabeledCollectionHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 03/03/2023.
//

import UIKit

// MARK: - LabeledCollectionHeaderView Type

final class LabeledCollectionHeaderView: UICollectionReusableView, CollectionReusableView {
    fileprivate(set) lazy var titleLabel: UILabel = createTitleLabel()
    
    func viewDidLoad() {
        viewHierarchyWillConfigure()
    }
    
    func viewHierarchyWillConfigure() {
        titleLabel
            .addToHierarchy(on: self)
            .constraintBottom(toParent: self, withBottomAnchor: -8.0)
    }
}

// MARK: - Private Implementation

extension LabeledCollectionHeaderView {
    private func createTitleLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = "Searches"
        label.font = .systemFont(ofSize: 18.0, weight: .bold)
        label.textColor = .white
        return label
    }
}
