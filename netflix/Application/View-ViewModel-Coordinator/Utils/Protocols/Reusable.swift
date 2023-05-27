//
//  Reusable.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import Foundation

// MARK: - Reusable Type

protocol Reusable {}

// MARK: - Reusable Implementation

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
