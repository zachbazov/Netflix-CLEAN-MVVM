//
//  UIView+Animations.swift
//  netflix
//
//  Created by Zach Bazov on 19/09/2022.
//

import UIKit

// MARK: - UIView + Animations (Spring)

extension UIView {
    func animateUsingSpring(withDuration duration: TimeInterval,
                            withDamping damping: CGFloat,
                            initialSpringVelocity velocity: CGFloat) {
        UIView.animate(withDuration: duration,
                       delay: .zero,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity) { [unowned self] in
            layoutIfNeeded()
        }
    }
    
    func animateUsingSpring(withDuration duration: TimeInterval,
                            withDamping damping: CGFloat,
                            initialSpringVelocity velocity: CGFloat,
                            animations: @escaping () -> Void,
                            completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: .zero,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       animations: animations,
                       completion: completion)
    }
}

// MARK: - UIView + Animations (Alpha)

extension UIView {
    
    // MARK: Properties
    
    private var defaultAnimationDuration: TimeInterval { return 0.3 }
    private var semiTransparent: CGFloat { return 0.5 }
    private var nonTransparent: CGFloat { return 1.0 }
    
    // MARK: Methods
    
    func setAlphaAnimation(using gesture: UIGestureRecognizer? = nil,
                           duration: TimeInterval? = nil,
                           alpha: CGFloat? = nil,
                           completion: @escaping () -> Void) {
        guard let gesture = gesture else { return }
        UIView.animate(withDuration: duration ?? defaultAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.alpha = alpha ?? self.semiTransparent
            self.isUserInteractionEnabled = false
        }
        if gesture.state == .ended {
            UIView.animate(withDuration: duration ?? defaultAnimationDuration) { [weak self] in
                guard let self = self else { return }
                self.alpha = alpha ?? self.nonTransparent
                self.isUserInteractionEnabled = true
                completion()
            }
        }
    }
}
