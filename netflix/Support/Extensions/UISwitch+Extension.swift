//
//  UISwitch+Extension.swift
//  netflix
//
//  Created by Developer on 31/08/2023.
//

import UIKit

// MARK: - UISwitch + Add Target

extension UISwitch {
    func addTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}
