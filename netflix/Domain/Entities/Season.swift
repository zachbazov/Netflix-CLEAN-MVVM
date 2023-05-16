//
//  Season.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Season Type

struct Season {
    var mediaId: String
    var title: String
    var slug: String
    var season: Int
    var episodes: [Episode]
}

// MARK: - Vacant Value

extension Season {
    static var vacantValue: Season {
        return Season(mediaId: .toBlank(), title: .toBlank(), slug: .toBlank(), season: .zero, episodes: [])
    }
}
