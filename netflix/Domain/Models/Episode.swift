//
//  Episode.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Episode Type

struct Episode {
    var id: String?
    let mediaId: String
    let title: String
    let slug: String
    let season: Int
    let episode: Int
    let url: String
}

// MARK: - MediaRepresentable Implementation

extension Episode: MediaRepresentable {}
