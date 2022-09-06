//
//  UIBarButtonItem+AddTarget.swift
//  netflix
//
//  Created by Zach Bazov on 06/09/2022.
//

import UIKit

// MARK: - UIBarButtonItem + AddTarget

extension UIBarButtonItem {
    func addTarget(_ target: AnyObject?, action: Selector) {
        self.target = target
        self.action = action
    }
}
