//
//  ListHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - ListHTTP Type

struct ListHTTP: HTTPRepresentable {
    struct Request {
        let user: User
    }

    struct Response {
        let status: String
        let data: List<Media>
    }
}
