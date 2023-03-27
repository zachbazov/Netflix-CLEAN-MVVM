//
//  Optional+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 21/03/2023.
//

import Foundation

// MARK: - Optional Extension

extension Optional {
    var isNil: Bool { self == nil }
    var isNotNil: Bool { self != nil }
}
