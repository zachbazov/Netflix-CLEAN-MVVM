//
//  OpaqueView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var blurView: UIVisualEffectView! { get }
    
    func viewDidUpdate()
}

// MARK: - OpaqueView Type

final class OpaqueView: UIView {
    var blurView: UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        remove()
    }
    
    func viewDidConfigure() {
        guard blurView.isNil else { return }
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = .init(effect: blurEffect)
        blurView.frame = bounds
    }
    
    func add() {
        guard blurView.isNotNil else { return }
        self.alpha = 1.0
        insertSubview(blurView, at: 0)
    }
    
    func remove() {
        guard blurView.isNotNil else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                self.alpha = .zero
            }, completion: { [weak self] done in
                guard let self = self else { return }
                self.blurView?.removeFromSuperview()
                self.blurView = nil
            })
    }
}

// MARK: - ViewProtocol Implementation

extension OpaqueView: ViewProtocol {
    /// Release changes for the view by the view model.
    /// - Parameter media: Corresponding media object.
    func viewDidUpdate() {
        viewDidConfigure()
    }
}
