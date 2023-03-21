//
//  UserProfileHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

protocol Gen {
    associatedtype T: Decodable
}

// MARK: - UserProfileHTTPDTO Type

struct UserProfileHTTPDTO {
    struct GET: HTTP {
        struct Request: Decodable {
            let user: UserDTO
        }
        
        struct Response: Decodable {
            let status: String
            let results: Int
            let data: [UserProfileDTO]
        }
    }
    
    struct POST: HTTP {
        struct Request: Decodable {
            let user: UserDTO
            let profile: UserProfileDTO
        }
        
        struct Response: Decodable {
            let status: String
            let data: UserProfileDTO
        }
    }
    
    struct PATCH: HTTP {
        struct Request: Decodable {
            let user: UserDTO
        }
        
        struct Response: Decodable {
            let status: String
            let data: UserProfileDTO
        }
    }
}

// MARK: - Mappings

extension UserProfileHTTPDTO.GET.Request {
    func toDomain() -> UserProfileHTTP.GET.Request {
        return .init(user: user.toDomain())
    }
}

extension UserProfileHTTPDTO.GET.Response {
    func toDomain() -> UserProfileHTTP.GET.Response {
        return .init(status: status, results: results, data: data.toDomain())
    }
}

extension UserProfileHTTPDTO.POST.Request {
    func toDomain() -> UserProfileHTTP.POST.Request {
        return .init(user: user.toDomain(), profile: profile.toDomain())
    }
}

extension UserProfileHTTPDTO.POST.Response {
    func toDomain() -> UserProfileHTTP.POST.Response {
        return .init(status: status, data: data.toDomain())
    }
}

extension UserProfileHTTPDTO.PATCH.Request {
    func toDomain() -> UserProfileHTTP.PATCH.Request {
        return .init(user: user.toDomain())
    }
}

extension UserProfileHTTPDTO.PATCH.Response {
    func toDomain() -> UserProfileHTTP.PATCH.Response {
        return .init(status: status, data: data.toDomain())
    }
}
