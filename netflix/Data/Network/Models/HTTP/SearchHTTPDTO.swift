//
//  SearchHTTPDTO.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - SearchHTTPDTO Type

struct SearchHTTPDTO: HTTPRepresentable {
    struct Request: Equatable {
        let regex: String
    }

    struct Response: Decodable {
        let status: String
        let results: Int
        let data: [MediaDTO]
    }
}
