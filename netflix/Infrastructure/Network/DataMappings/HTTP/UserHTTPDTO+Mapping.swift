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
        let selectedProfile: String?
    }
    
    struct Response: Decodable {
        var status: String?
        let token: String?
        let data: UserDTO?
        var request: Request?
    }
}

// MARK: - Mapping

extension UserHTTPDTO.Request {
    func toDomain() -> UserHTTP.Request {
        return .init(user: user.toDomain(), selectedProfile: selectedProfile)
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

extension UserHTTPDTO.Request {
    func toEntity(in context: NSManagedObjectContext) -> AuthRequestEntity {
        let entity: AuthRequestEntity = .init(context: context)
        entity.user?._id = user._id
        entity.user?.name = user.name
        entity.user?.email = user.email
        entity.user?.password = user.password
        entity.user?.passwordConfirm = user.passwordConfirm
        entity.user?.role = user.role
        entity.user?.active = user.active
        entity.user?.token = user.token
        entity.user?.selectedProfile = user.selectedProfile
        return entity
    }
}

extension UserHTTPDTO.Response {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity {
        let entity: AuthResponseEntity = .init(context: context)
        entity.status = status
        entity.token = token
        entity.data = data
        return entity
    }
}
