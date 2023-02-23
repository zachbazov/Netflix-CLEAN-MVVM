//
//  UIView+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - UIView + Gradients

extension UIView {
    func addGradientLayer(colors: [UIColor],
                          locations: [NSNumber],
                          points: [CGPoint]? = nil) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        gradient.type = .axial
        
        if let points = points {
            gradient.startPoint = points.first!
            gradient.endPoint = points.last!
        }
        
        self.layer.addSublayer(gradient)
    }
}

// MARK: - UIView + Visibility

extension UIView {
    func isHidden(_ hidden: Bool) {
        guard !hidden else {
            isHidden = true
            alpha = 0.0
            return
        }
        isHidden = false
        alpha = 1.0
    }
}

// MARK: - Blurness

extension UIView {
    func addBlurness() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurView, at: 0)
        
        blurView.constraintToSuperview(self)
    }
}
