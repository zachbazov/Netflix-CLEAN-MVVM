//
//  UIImage+Rendering.swift
//  netflix
//
//  Created by Zach Bazov on 19/09/2022.
//

import UIKit

// MARK: - UIImage + Rendering

extension UIImage {
    func whiteRendering(with symbolConfiguration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        return self
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
            .withConfiguration(symbolConfiguration ?? .unspecified)
    }
    
    static func fillGradientStroke(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
    
    func setThemeTintColor(with symbolConfiguration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        return self
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(Theme.currentTheme == .dark ? .white : .black)
            .withConfiguration(symbolConfiguration ?? .unspecified)
    }
    
    static var themeControlImage: UIImage? {
        return Theme.currentTheme == .dark
            ? UIImage(systemName: "sun.max")?.setThemeTintColor()
            : UIImage(systemName: "moon")?.setThemeTintColor()
    }
}
