//
//  UICollectionView+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 12/10/2022.
//

import UIKit

// MARK: - UICollectionView + Register

extension UICollectionView {
    func registerNib(_ views: UIView.Type...) {
        views.forEach { [unowned self] in
            let nib = UINib(nibName: String(describing: $0), bundle: nil)
            register(nib, forCellWithReuseIdentifier: String(describing: $0))
        }
    }
}

// MARK: - UICollectionView + Constraints

extension UICollectionView {
    func constraintCenterToSuperview(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            widthAnchor.constraint(equalToConstant: view.bounds.width),
            heightAnchor.constraint(equalToConstant: view.bounds.height)
        ])
    }
}

// MARK: - UICollectionView + Add Gestures

extension UICollectionView {
    func addTapGesture(_ target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
    }
}
