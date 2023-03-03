//
//  CollectionViewHeaderView.swift
//  netflix
//
//  Created by Zach Bazov on 03/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var titleLabel: UILabel { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - CollectionViewHeaderView Type

final class CollectionViewHeaderView: UICollectionReusableView {
    
    fileprivate lazy var titleLabel: UILabel = createTitleLabel()
    
    static func create(in collectionView: UICollectionView, at indexPath: IndexPath) -> CollectionViewHeaderView {
        guard let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath) as? CollectionViewHeaderView else { fatalError() }
        cell.viewDidConfigure()
        return cell
    }
    
    func viewDidConfigure() {
        _ = titleLabel
    }
}

// MARK: - Reusable Implementation

extension CollectionViewHeaderView: Reusable {}

// MARK: - ViewLifecycleBehavior Implementation

extension CollectionViewHeaderView: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension CollectionViewHeaderView: ViewProtocol {}

// MARK: - Private UI Implementation

extension CollectionViewHeaderView {
    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = "Top Searches"
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = .white
        addSubview(titleLabel)
        titleLabel.constraintBottom(toParent: self, withBottomAnchor: -8.0)
        return titleLabel
    }
}
