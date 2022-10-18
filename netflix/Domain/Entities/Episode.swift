//
//  Episode.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Episode struct

struct Episode {
    var id: String?
    var mediaId: String
    var title: String
    var slug: String
    var season: Int
    var episode: Int
    var url: String
}

// MARK: - Episode: Mediable implementation

extension Episode: Mediable {}
