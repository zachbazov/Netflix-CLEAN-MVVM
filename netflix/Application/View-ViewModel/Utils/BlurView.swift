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
    var view: UIVisualEffectView?
    
    private let parent: UIView
    
    deinit {
//        print("deinit BlurView")
        
        view?.removeFromSuperview()
        
        removeFromSuperview()
    }
    
    init(on parent: UIView, effect: UIBlurEffect) {
        self.parent = parent
        self.effect = effect
        
        super.init(frame: .zero)
        
        self.view = UIVisualEffectView(effect: effect)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func add() {
        parent.backgroundColor = .clear
        guard let view = view else { return }
        parent.insertSubview(view, at: .zero)
        view.constraintToSuperview(parent)
    }
    
    func remove() {
        view?.removeFromSuperview()
    }
}
