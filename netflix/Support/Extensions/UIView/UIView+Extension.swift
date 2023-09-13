//
//  UIView+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import AVKit

// MARK: - UIView + Hierarchy

extension UIView {
    @discardableResult
    func addToHierarchy(on view: UIView) -> Self {
        view.addSubview(self)
        return self
    }
}

// MARK: - UIView + Styling

extension UIView {
    @discardableResult
    func setBackgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
}

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
    
    @discardableResult
    func hidden(_ hidden: Bool) -> Self {
        guard !hidden else {
            isHidden = true
            alpha = 0.0
            return self
        }
        
        isHidden = false
        alpha = 1.0
        return self
    }
}

// MARK: - Layer

extension UIView {
    @discardableResult
    func cornerRadius(_ value: CGFloat) -> Self {
        layer.cornerRadius = value
        
        return self
    }
    
    @discardableResult
    func border(_ color: UIColor, width: CGFloat) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        
        return self
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

// MARK: - AVRoutePickerView

extension UIView {
    func toRoutePickerView() {
        let airPlay = AVRoutePickerView(frame: bounds)
        airPlay.tintColor = .white
        airPlay.prioritizesVideoDevices = true
        addSubview(airPlay)
    }
    
    var isRoutePickerView: Bool {
        for subview in subviews {
            if subview is AVRoutePickerView {
                return true
            }
        }
        return false
    }
}

// MARK: - Frame

extension UIView {
    func origin(y: CGFloat) {
        frame.origin.y = y
    }
}

// MARK: - Target

extension UIViewController {
    func onTapResignFirstResponder() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleResignFirstResponder))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleResignFirstResponder() {
        view.endEditing(true)
    }
}

extension UIView {
    func addTapGesture(_ target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
    }
    
    func addLongPressTarget(_ target: Any, selector: Selector) {
        let longPress = UILongPressGestureRecognizer(target: target, action: selector)
        addGestureRecognizer(longPress)
    }
}
