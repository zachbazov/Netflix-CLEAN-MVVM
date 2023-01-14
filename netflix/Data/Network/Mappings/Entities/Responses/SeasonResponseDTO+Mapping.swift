//
//  SeasonResponseDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonResponseDTO Type

struct SeasonResponseDTO {
    
    // MARK: GET Type
    
    struct GET: Decodable {
        let status: String
        var data: [SeasonDTO]
    }
}

// MARK: - Mapping

extension SeasonResponseDTO.GET {
    func toDomain() -> SeasonResponse.GET {
        return .init(status: status,
                     data: data.first?.toDomain() ?? .init(mediaId: "", title: "", slug: "", season: 0, episodes: []))
    }
}
