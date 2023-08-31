//
//  UITextField+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - UITextField + Attributes

extension UITextField {
    func setPlaceholderAtrributes(string: String, attributes: [NSAttributedString.Key: Any]?) {
        attributedPlaceholder = NSAttributedString(string: string, attributes: attributes)
    }
    
    func setTextAtrributes(string: String, attributes: [NSAttributedString.Key: Any]?) {
        attributedText = NSAttributedString(string: string, attributes: attributes)
    }
}
