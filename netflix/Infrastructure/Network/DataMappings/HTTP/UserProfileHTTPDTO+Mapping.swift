//
//  UserProfileHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - UserProfileHTTPDTO Type

struct UserProfileHTTPDTO: HTTP {
    struct Request: Decodable {
        let user: UserDTO
    }
    
    struct Response: Decodable {
        let status: String
        let results: Int
        let data: [UserProfileDTO]
    }
}

// MARK: - Mappings

extension UserProfileHTTPDTO.Request {
    func toDomain() -> UserProfileHTTP.Request {
        return .init(user: user.toDomain())
    }
}

extension UserProfileHTTPDTO.Response {
    func toDomain() -> UserProfileHTTP.Response {
        return .init(status: status, results: results, data: data.toDomain())
    }
}
