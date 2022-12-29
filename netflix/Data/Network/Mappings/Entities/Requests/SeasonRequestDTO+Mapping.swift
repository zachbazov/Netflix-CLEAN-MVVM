//
//  SeasonRequestDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonRequestDTO Type

struct SeasonRequestDTO {
    
    // MARK: GET Type
    
    struct GET: Decodable {
        var id: String? = nil
        var slug: String? = nil
        var season: Int? = 1
    }
}

// MARK: - Mapping

extension SeasonRequestDTO.GET {
    func toDomain() -> SeasonRequest.GET {
        return .init()
    }
}
