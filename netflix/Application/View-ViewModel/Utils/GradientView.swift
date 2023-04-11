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
    
    func setupGradient(with colors: [UIColor]) {
        view?.layer.removeFromSuperlayer()
        
        guard !colors.isEmpty else { return }
        
        view = UIView(frame: parent.bounds)
        
        let color1 = colors[0]
        let color2 = colors[1]
        let color3 = colors[2]
        
        gradientLayer.frame = view!.bounds
        gradientLayer.colors = [color3.cgColor,
                                color3.cgColor,
                                color2.cgColor,
                                color1.cgColor]
        gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
        
        view?.layer.addSublayer(gradientLayer)
        parent.insertSubview(view!, at: .zero)
    }
}
