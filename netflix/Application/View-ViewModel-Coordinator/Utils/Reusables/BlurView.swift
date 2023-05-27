//
//  BlurView.swift
//  netflix
//
//  Created by Zach Bazov on 11/04/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var effect: UIBlurEffect { get }
    var view: UIVisualEffectView { get }
    
    func draw() -> Self
    func remove()
}

// MARK: - BlurView Type

final class BlurView: UIView {
    fileprivate let effect: UIBlurEffect
    fileprivate let view: UIVisualEffectView
    
    private let parent: UIView
    
    init(on parent: UIView, effect: UIBlurEffect) {
        self.parent = parent
        self.effect = effect
        self.view = UIVisualEffectView(effect: effect)
        
        super.init(frame: .zero)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func viewDidLoad() {
        viewWillConfigure()
    }
    
    func viewWillConfigure() {
        parent.setBackgroundColor(.clear)
    }
}

// MARK: - ViewProtocol Implementation

extension BlurView: ViewProtocol {
    func draw() -> Self {
        parent.insertSubview(view, at: .zero)
        view.constraintToSuperview(parent)
        
        return self
    }
    
    func remove() {
        view.removeFromSuperview()
        
        removeFromSuperview()
    }
}
