//
//  String+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - String Extension

extension String {
    static var success: String { return "success" }
    
    var isNotEmpty: Bool { return !self.isEmpty }
    
    mutating func toBlankValue() { self = "" }
}
