//
//  List.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - List Type

struct List<T> {
    let user: String
    var media: [T]
}
