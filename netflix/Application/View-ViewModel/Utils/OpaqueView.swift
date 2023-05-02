//
//  OpaqueView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var blurView: UIVisualEffectView { get }
}

// MARK: - OpaqueView Type

final class OpaqueView: UIView {
    fileprivate lazy var blurView: UIVisualEffectView = createVisualEffectView()
    
    deinit {
        print("deinit \(Self.self)")
    }
    
    fileprivate func createVisualEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        return blurView
    }
    
    func apply() -> Self {
        insertSubview(blurView, at: 0)
        
        return self
    }
}

// MARK: - ViewProtocol Implementation

extension OpaqueView: ViewProtocol {}
