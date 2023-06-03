//
//  UserHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - UserHTTP Type

struct UserHTTP: HTTP {
    struct Request {
        let user: User
        let selectedProfile: String?
    }

    struct Response {
        var status: String?
        let token: String?
        var data: User?
        var request: Request?
    }
}
