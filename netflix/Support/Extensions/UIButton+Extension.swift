//
//  UIButton+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - UIButton Extension

extension UIButton {
    @discardableResult
    func round() -> Self {
        layer.cornerRadius = bounds.height / 2
        
        return self
    }
    
    func toggle() {
        isSelected = !isSelected
    }
    
    func toggle(_ contains: Bool) {
        isSelected = contains
    }
}
