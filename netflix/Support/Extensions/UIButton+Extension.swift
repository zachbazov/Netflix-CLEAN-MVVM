//
//  UIButton+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - UIButton Extension

extension UIButton {
    func border(_ color: UIColor, width: CGFloat) -> Self {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        
        return self
    }
    
    @discardableResult
    func round() -> Self {
        layer.cornerRadius = bounds.height / 2
        
        return self
    }
}
