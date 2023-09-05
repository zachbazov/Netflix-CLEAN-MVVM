//
//  EditOverlayView.swift
//  netflix
//
//  Created by Developer on 24/08/2023.
//

import UIKit

// MARK: - EditOverlayView Type

final class EditOverlayView: UIView {
    private let parent: UIView
    
    private(set) var foreground: UIView?
    private var imageView: UIImageView?
    
    deinit {
        viewDidDeallocate()
    }
    
    init(on parent: UIView) {
        self.parent = parent
        
        super.init(frame: .zero)
        
        self.layoutSubviews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewDidDeploySubviews()
    }
    
    func viewDidDeploySubviews() {
        createForegroundView()
        createImageView()
    }
    
    func viewDidDeallocate() {
        foreground?.removeFromSuperview()
        foreground = nil
        imageView?.removeFromSuperview()
        imageView = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension EditOverlayView: ViewLifecycleBehavior {}

// MARK: - Private Implementation

extension EditOverlayView {
    private func createForegroundView() {
        foreground = UIView(frame: bounds)
            .addToHierarchy(on: parent)
            .constraintToSuperview(parent)
            .hidden(true)
            .cornerRadius(4.0)
            .setBackgroundColor(UIColor.black.withAlphaComponent(0.5))
    }
    
    private func createImageView() {
        guard let foreground = self.foreground else { return }
        
        imageView = UIImageView(image: .pencil)
            .addToHierarchy(on: foreground)
            .constraintCenterToSuperview(in: parent, withRadiusValue: 40.0)
    }
}
