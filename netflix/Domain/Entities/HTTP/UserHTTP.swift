//
//  UserHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - UserHTTP Type

struct UserHTTP {
    struct GET: HTTP {
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
    
    struct POST: HTTP {
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
    
    struct PATCH: HTTP {
        struct Request {
            let user: User
            let selectedProfile: String?
        }

        struct Response {
            let status: String
            var data: User?
            let message: String?
        }
    }
}
