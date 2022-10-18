//
//  SeasonDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - SeasonDTO struct

struct SeasonDTO: Decodable {
    let mediaId: String
    let title: String
    let slug: String
    let season: Int
    let episodes: [EpisodeDTO]
}

// MARK: - Mapping

extension SeasonDTO {
    func toDomain() -> Season {
        return .init(mediaId: mediaId,
                     title: title,
                     slug: slug,
                     season: season,
                     episodes: episodes.map { $0.toDomain() })
    }
}
