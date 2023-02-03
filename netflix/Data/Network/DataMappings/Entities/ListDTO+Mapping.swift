//
//  ListDTO+Mapping.swift
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

extension ListDTO<MediaDTO> {
    func toDomain() -> List<Media> {
        return .init(user: user, media: media.map { $0.toDomain() })
    }
}

extension ListDTO<String> {
    func toDomain() -> List<String> {
        return .init(user: user, media: media)
    }
}
