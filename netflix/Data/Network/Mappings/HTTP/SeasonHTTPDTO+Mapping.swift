//
//  SeasonHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - SeasonHTTP Type

struct SeasonHTTPDTO: HTTP {
    struct Request {
        var id: String? = nil
        var slug: String? = nil
        var season: Int? = 1
    }

    struct Response: Decodable {
        let status: String
        var data: [SeasonDTO]
    }
}

// MARK: - Mapping

extension SeasonHTTPDTO.Request {
    func toDomain() -> SeasonHTTP.Request {
        return .init()
    }
}

extension SeasonHTTPDTO.Response {
    func toDomain() -> SeasonHTTP.Response {
        return .init(status: status,
                     data: data.first?.toDomain() ?? .init(mediaId: "", title: "", slug: "", season: 0, episodes: []))
    }
}
