//
//  SeasonHTTPDTO.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - SeasonHTTP Type

struct SeasonHTTPDTO: HTTPRepresentable {
    struct Request: Decodable {
        var id: String?
        var slug: String?
        var season: Int?
    }

    struct Response: Decodable {
        let status: String
        let data: [SeasonDTO]
    }
}

// MARK: - Mapping

extension SeasonHTTPDTO.Request {
    func toDomain() -> SeasonHTTP.Request {
        return .init(id: id, slug: slug, season: season)
    }
}

extension SeasonHTTPDTO.Response {
    func toDomain() -> SeasonHTTP.Response {
        return .init(status: status,
                     data: data.first?.toDomain() ?? .init(mediaId: .toBlank(), title: .toBlank(), slug: .toBlank(), season: .zero, episodes: []))
    }
}
