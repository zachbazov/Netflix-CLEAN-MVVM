//
//  CALayer+Shadow.swift
//  netflix
//
//  Created by Zach Bazov on 19/09/2022.
//

import UIKit

// MARK: - CALayer Extension

extension CALayer {
    func shadow(_ color: UIColor, radius: CGFloat, opacity: Float) {
        shadowColor = color.cgColor
        shadowOffset = .zero
        shadowRadius = radius
        shadowOpacity = opacity
    }
}
