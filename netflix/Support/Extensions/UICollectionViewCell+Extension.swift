//
//  UICollectionViewCell+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - ViewInstantiable Implementation

extension UICollectionViewCell: ViewInstantiable {}

// MARK: - Animations Implementation

extension UICollectionViewCell {
    func opacityAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        layer.add(animation, forKey: "opacity")
    }
}
