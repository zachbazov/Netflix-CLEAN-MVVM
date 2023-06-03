//
//  UserHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - UserHTTP Type

struct UserHTTP: HTTPRepresentable {
    struct Request {
        let user: User
        var selectedProfile: String?
    }

    struct Response {
        var status: String?
        var token: String?
        var data: User?
        var request: Request?
    }
}
