//
//  UserProfileHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - UserProfileHTTP Type

struct UserProfileHTTP {
    struct GET: HTTP {
        struct Request {
            let user: User
        }
        
        struct Response {
            let status: String
            let results: Int
            let data: [UserProfile]
        }
    }
    
    struct POST: HTTP {
        struct Request {
            let user: User
            let profile: UserProfile
        }
        
        struct Response {
            let status: String
            let data: UserProfile
        }
    }
    
    struct PATCH: HTTP {
        struct Request {
            let user: User
        }
        
        struct Response {
            let status: String
            let data: UserProfile
        }
    }
}
