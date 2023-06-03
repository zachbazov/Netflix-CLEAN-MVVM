//
//  ProfileHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - ProfileHTTPDTO Type

struct ProfileHTTPDTO {
    struct GET: HTTP {
        struct Request: Decodable {
            let user: UserDTO
        }
        
        struct Response: Decodable {
            let status: String
            let results: Int
            let data: [ProfileDTO]
        }
    }
    
    struct POST: HTTP {
        struct Request: Decodable {
            let user: UserDTO
            let profile: ProfileDTO
        }
        
        struct Response: Decodable {
            let status: String
            let data: ProfileDTO
        }
    }
    
    struct PATCH: HTTP {
        struct Request: Decodable {
            let user: UserDTO
        }
        
        struct Response: Decodable {
            let status: String
            let data: ProfileDTO
        }
    }
}

// MARK: - Mappings

extension ProfileHTTPDTO.GET.Request {
    func toDomain() -> ProfileHTTP.GET.Request {
        return .init(user: user.toDomain())
    }
}

extension ProfileHTTPDTO.GET.Response {
    func toDomain() -> ProfileHTTP.GET.Response {
        return .init(status: status, results: results, data: data.toDomain())
    }
}

extension ProfileHTTPDTO.POST.Request {
    func toDomain() -> ProfileHTTP.POST.Request {
        return .init(user: user.toDomain(), profile: profile.toDomain())
    }
}

extension ProfileHTTPDTO.POST.Response {
    func toDomain() -> ProfileHTTP.POST.Response {
        return .init(status: status, data: data.toDomain())
    }
}

extension ProfileHTTPDTO.PATCH.Request {
    func toDomain() -> ProfileHTTP.PATCH.Request {
        return .init(user: user.toDomain())
    }
}

extension ProfileHTTPDTO.PATCH.Response {
    func toDomain() -> ProfileHTTP.PATCH.Response {
        return .init(status: status, data: data.toDomain())
    }
}
