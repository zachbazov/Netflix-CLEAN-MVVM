//
//  NavigationStylable.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - NavigationStylable Type

protocol NavigationStylable {
    func titleViewWillConfigure(withAssetNamed asset: String)
}
