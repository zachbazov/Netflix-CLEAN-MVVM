//
//  CGRect+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 28/04/2023.
//

import UIKit

// MARK: - CGRect Extension

extension CGRect {
    static var screenSize: CGRect {
        return CGRect(x: .zero, y: .zero, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
