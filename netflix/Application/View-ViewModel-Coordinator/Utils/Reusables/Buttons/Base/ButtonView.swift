//
//  ButtonView.swift
//  netflix
//
//  Created by Developer on 06/09/2023.
//

import UIKit

// MARK: - RespondableButton Type

private protocol RespondableButton {
    func buttonWillBeginTapping()
    func buttonWillEndTapping()
    func buttonDidTap()
}

// MARK: - ButtonView Type

@IBDesignable
class ButtonView: UIView {
    let defaultAlpha: CGFloat = 1.0
    
    @IBInspectable
    var effectAlpha: CGFloat = 0.5 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable
    var radius: CGFloat = 8.0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable
    var bgColor: UIColor = UIColor.hexColor("#282828") {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewDidTargetSubviews()
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewDidTargetSubviews()
        self.viewDidConfigure()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        bgColor.setFill()
        path.fill()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension ButtonView: ViewLifecycleBehavior {
    func viewDidTargetSubviews() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(buttonDidTap))
        addGestureRecognizer(tap)
    }
    
    func viewDidConfigure() {
        alpha = defaultAlpha
    }
}

// MARK: - UIResponder Implementation

extension ButtonView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonWillBeginTapping()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonWillEndTapping()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonWillEndTapping()
    }
}

// MARK: - RespondableButton Implementation

extension ButtonView: RespondableButton {
    @objc
    open func buttonWillBeginTapping() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            alpha = effectAlpha
        }
    }
    
    @objc
    open func buttonWillEndTapping() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            alpha = defaultAlpha
        }
    }
    
    @objc
    open func buttonDidTap() {}
}
