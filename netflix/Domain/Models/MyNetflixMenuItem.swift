//
//  MyNetflixMenuItem.swift
//  netflix
//
//  Created by Developer on 10/09/2023.
//

import Foundation

// MARK: - MyNetflixMenuItem Type

struct MyNetflixMenuItem {
    var image: String?
    let title: String
    var isExpanded: Bool?
    var items: [Media]?
    var color: Color?
    let hasImage: Bool
    let hasAccessory: Bool
}
