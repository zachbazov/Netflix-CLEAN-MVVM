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
    var gradientView: UIView { get }
    
    func createVisualEffectView() -> UIVisualEffectView
    func createGradientView() -> UIView
    func apply() -> Self
}

// MARK: - OpaqueView Type

final class OpaqueView: UIView {
    fileprivate lazy var blurView: UIVisualEffectView = createVisualEffectView()
    fileprivate lazy var gradientView: UIView = createGradientView()
}

// MARK: - ViewProtocol Implementation

extension OpaqueView: ViewProtocol {
    fileprivate func createVisualEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        return blurView
    }
    
    fileprivate func createGradientView() -> UIView {
        let rect = CGRect(x: .zero, y: CGRect.screenSize.height - 192.0,
                          width: CGRect.screenSize.width, height: 192.0)
        gradientView = .init(frame: rect)
        gradientView.addGradientLayer(colors: [.clear, .hexColor("#050505")], locations: [0.0, 0.85])
        return gradientView
    }
    
    func apply() -> Self {
        insertSubview(blurView, at: 0)
        addSubview(gradientView)
        
        return self
    }
}
