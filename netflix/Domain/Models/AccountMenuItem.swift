//
//  AccountOption.swift
//  netflix
//
//  Created by Zach Bazov on 11/03/2023.
//

import Foundation

// MARK: - AccountMenuItem Type

struct AccountMenuItem {
    let image: String
    let title: String
    var options: [Media]?
    var isExpanded: Bool?
}
