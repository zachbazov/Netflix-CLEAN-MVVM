//
//  GradientView.swift
//  netflix
//
//  Created by Zach Bazov on 11/04/2023.
//

import UIKit

// MARK: - GradientView Type

final class GradientView: UIView {
    let parent: UIView
    var view: UIView?
    let gradientLayer = CAGradientLayer()
    
    deinit {
        print("deinit GradientView")
    }
    
    init(on parent: UIView) {
        self.parent = parent
        self.view = UIView(frame: .zero)
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @discardableResult
    func applyGradient(with colors: [UIColor]) -> Self {
        view?.layer.removeFromSuperlayer()
        
        guard !colors.isEmpty else { return self }
        
        view = UIView(frame: parent.bounds)
        
        gradientLayer.frame = view!.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
        
        view?.layer.addSublayer(gradientLayer)
        parent.insertSubview(view!, at: .zero)
        
        return self
    }
    
    func remove() {
        guard let view = view else { return }
        
        view.removeFromSuperview()
    }
}