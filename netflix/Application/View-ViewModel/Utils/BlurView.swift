//
//  BlurView.swift
//  netflix
//
//  Created by Zach Bazov on 11/04/2023.
//

import UIKit

// MARK: - BlurView Type

final class BlurView: UIView {
    let effect: UIBlurEffect
    let view: UIVisualEffectView
    
    deinit {
        print("deinit BlurView")
        view.removeFromSuperview()
    }
    
    init(on parent: UIView, effect: UIBlurEffect) {
        self.effect = effect
        self.view = UIVisualEffectView(effect: effect)
        
        super.init(frame: .zero)
        
        parent.backgroundColor = .clear
        parent.insertSubview(view, at: .zero)
        view.constraintToSuperview(parent)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
