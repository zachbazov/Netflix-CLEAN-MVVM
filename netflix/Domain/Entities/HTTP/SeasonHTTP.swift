//
//  SeasonHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - SeasonHTTP Type

struct SeasonHTTP {
    struct Request {
        var id: String? = nil
        var slug: String? = nil
        var season: Int? = 1
    }

    struct Response {
        let status: String
        var data: Season?
    }
}
