//
//  Season.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Season Type

struct Season {
    let mediaId: String
    let title: String
    let slug: String
    let season: Int
    let episodes: [Episode]
}

// MARK: - Vacant Value

extension Season {
    static var vacantValue: Season {
        return Season(mediaId: .toBlank(), title: .toBlank(), slug: .toBlank(), season: .zero, episodes: [])
    }
}
