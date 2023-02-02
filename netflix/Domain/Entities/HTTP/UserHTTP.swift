//
//  UserHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - UserHTTP Type

struct UserHTTP {
    struct Request {
        let user: User
    }

    struct Response {
        var status: String?
        let token: String
        var data: User?
        var request: Request?
    }
}
