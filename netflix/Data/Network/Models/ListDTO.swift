//
//  ListDTO.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListDTO Type

final class ListDTO<T: Decodable>: Decodable {
    let user: String
    let media: [T]
}

// MARK: - Mapping

extension ListDTO where T == MediaDTO {
    func toDomain() -> List<Media> {
        return List(user: user, media: media.map { $0.toDomain() })
    }
}

extension ListDTO where T == String {
    func toDomain() -> List<String> {
        return List(user: user, media: media)
    }
}
