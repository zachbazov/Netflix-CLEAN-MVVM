//
//  BadgeView.swift
//  netflix
//
//  Created by Developer on 21/08/2023.
//

import UIKit

// MARK: - BadgeView Type

final class BadgeView: UIView {
    private let image: UIImageView
    private let badge: Badgable
    
    init(on parent: UIView, badge: Badgable) {
        self.image = UIImageView()
        self.badge = badge
        
        super.init(frame: parent.bounds)
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        parent.cornerRadius(12.0)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func viewDidLoad() {
        viewHierarchyDidConfigure()
        viewDidConfigure()
    }
    
    func viewHierarchyDidConfigure() {
        image
            .addToHierarchy(on: self)
            .constraintToCenterSuperview(self)
    }
    
    func viewDidConfigure() {
        let systemImage: UIImage?
        
        switch badge.badgeType {
        case .edit:
            systemImage = UIImage(systemName: "pencil")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.black)
        }
        
        image.image = systemImage
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension BadgeView: ViewLifecycleBehavior {}

