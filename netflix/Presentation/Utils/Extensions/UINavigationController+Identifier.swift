//
//  UINavigationController+Identifier.swift
//  netflix
//
//  Created by Zach Bazov on 23/12/2022.
//

import UIKit

extension UINavigationController {
    var representedScreenIdentifier: Int? { return navigationBar.tag }
}
