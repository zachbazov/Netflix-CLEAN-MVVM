//
//  UserHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import CoreData

// MARK: - UserHTTPDTO Type

struct UserHTTPDTO: HTTP {
    
    struct Request: Decodable {
        let user: UserDTO
    }
    
    struct Response: Decodable {
        var status: String?
        let token: String
        let data: UserDTO?
        var request: Request?
    }
}

// MARK: - Mapping

extension UserHTTPDTO.Request {
    func toDomain() -> UserHTTP.Request {
        return .init(user: user.toDomain())
    }
}

extension UserHTTPDTO.Response {
    func toDomain() -> UserHTTP.Response {
        return .init(status: status,
                     token: token,
                     data: data?.toDomain(),
                     request: request?.toDomain())
    }
}

extension UserHTTPDTO.Response {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity? {
        guard let data = data else { return nil }
        let entity: AuthResponseEntity = .init(context: context)
        entity.status = status
        entity.token = token
        entity.data = data
        return entity
    }
}
