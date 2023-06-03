//
//  ProfileHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - ProfileHTTP Type

struct ProfileHTTP {
    struct GET: HTTP {
        struct Request {
            let user: User
        }
        
        struct Response {
            let status: String
            let results: Int
            let data: [Profile]
        }
    }
    
    struct POST: HTTP {
        struct Request {
            let user: User
            let profile: Profile
        }
        
        struct Response {
            let status: String
            let data: Profile
        }
    }
    
    struct PATCH: HTTP {
        struct Request {
            let user: User
        }
        
        struct Response {
            let status: String
            let data: Profile
        }
    }
}
