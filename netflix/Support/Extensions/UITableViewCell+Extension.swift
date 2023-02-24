//
//  UITableViewCell+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 14/09/2022.
//

import UIKit

// MARK: - ViewInstantiable Implementation

extension UITableViewCell: ViewInstantiable {}

// MARK: - Animations Implementation

extension UITableViewCell {
    func opacityAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        layer.add(animation, forKey: "opacity")
    }
}
