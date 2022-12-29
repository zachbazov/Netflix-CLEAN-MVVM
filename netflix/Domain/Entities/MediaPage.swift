//
//  MediaPage.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

// MARK: - MediaPage Type

struct MediaPage {
    let page: Int
    let totalPages: Int
    let media: [Media]
}

// MARK: - Equatable Implementation

extension MediaPage: Equatable {}
