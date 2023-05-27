//
//  GradientView.swift
//  netflix
//
//  Created by Zach Bazov on 11/04/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var view: UIView { get }
    var gradientLayer: CAGradientLayer { get }
    
    func configureLayer(with colors: [UIColor])
    func draw(with colors: [UIColor]) -> Self
    func remove()
}

// MARK: - GradientView Type

final class GradientView: UIView {
    fileprivate let view: UIView
    fileprivate let gradientLayer = CAGradientLayer()
    
    private let parent: UIView
    
    init(on parent: UIView) {
        self.parent = parent
        self.view = UIView(frame: parent.bounds)
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewProtocol Implementation

extension GradientView: ViewProtocol {
    func configureLayer(with colors: [UIColor]) {
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.3, 0.6, 1.0]
    }
    
    @discardableResult
    func draw(with colors: [UIColor]) -> Self {
        configureLayer(with: colors)
        
        view.layer.addSublayer(gradientLayer)
        parent.insertSubview(view, at: .zero)
        
        return self
    }
    
    func remove() {
        gradientLayer.removeFromSuperlayer()
        
        view.removeFromSuperview()
        
        removeFromSuperview()
    }
}
