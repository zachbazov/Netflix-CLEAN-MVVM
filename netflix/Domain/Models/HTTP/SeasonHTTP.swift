//
//  SeasonHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - SeasonHTTP Type

struct SeasonHTTP: HTTPRepresentable {
    struct Request {
        var id: String?
        var slug: String?
        var season: Int?
    }

    struct Response {
        let status: String
        var data: Season?
    }
}
