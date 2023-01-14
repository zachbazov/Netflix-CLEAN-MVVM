//
//  ListDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListDTO Type

struct ListDTO {
    
    struct GET: Decodable {
        let user: String
        let media: [MediaDTO]
    }
    
    struct POST: Decodable {
        let user: String
        let media: [String]
    }
}

// MARK: - Mapping

extension ListDTO.GET {
    func toDomain() -> List.GET {
        return .init(user: user, media: media.map { $0.toDomain() })
    }
}

extension ListDTO.POST {
    func toDomain() -> List.POST {
        return .init(user: user, media: media)
    }
}
