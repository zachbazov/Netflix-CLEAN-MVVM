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
    
    var gradientView: UIView?
    
    deinit {
        print("deinit \(Self.self)")
    }
    
    fileprivate func createVisualEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        
        let rect = CGRect(x: .zero, y: CGRect.screenSize.height - 192.0, width: CGRect.screenSize.width, height: 192.0)
        self.gradientView = .init(frame: rect)
        self.gradientView?.addGradientLayer(colors: [.clear, .hexColor("#050505")], locations: [0.0, 0.85])
        
        self.addSubview(self.gradientView!)
        
        return blurView
    }
    
    func apply() -> Self {
        insertSubview(blurView, at: 0)
        
        return self
    }
}

// MARK: - ViewProtocol Implementation

extension OpaqueView: ViewProtocol {}
