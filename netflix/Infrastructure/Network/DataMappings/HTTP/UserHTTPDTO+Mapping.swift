//
//  UserHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import CoreData

// MARK: - UserHTTPDTO Type

struct UserHTTPDTO {
    struct GET: HTTP {
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
    
    struct POST: HTTP {
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
    
    struct PATCH: HTTP {
        struct Request: Decodable {
            let user: UserDTO
            let selectedProfile: String?
        }
        
        struct Response: Decodable {
            var status: String
            let data: UserDTO?
            let message: String?
        }
    }
}

// MARK: - Mapping

extension UserHTTPDTO.GET.Request {
    func toDomain() -> UserHTTP.GET.Request {
        return .init(user: user.toDomain())
    }
}

extension UserHTTPDTO.GET.Response {
    func toDomain() -> UserHTTP.GET.Response {
        return .init(status: status,
                     token: token,
                     data: data?.toDomain(),
                     request: request?.toDomain())
    }
}

extension UserHTTPDTO.POST.Request {
    func toDomain() -> UserHTTP.POST.Request {
        return .init(user: user.toDomain())
    }
}

extension UserHTTPDTO.POST.Response {
    func toDomain() -> UserHTTP.POST.Response {
        return .init(status: status,
                     token: token,
                     data: data?.toDomain(),
                     request: request?.toDomain())
    }
}

extension UserHTTPDTO.PATCH.Request {
    func toDomain() -> UserHTTP.PATCH.Request {
        return .init(user: user.toDomain(), selectedProfile: selectedProfile)
    }
}

extension UserHTTPDTO.PATCH.Response {
    func toDomain() -> UserHTTP.PATCH.Response {
        return .init(status: status, data: data?.toDomain(), message: message)
    }
}

extension UserHTTPDTO.GET.Response {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity? {
        guard let data = data else { return nil }
        let entity: AuthResponseEntity = .init(context: context)
        entity.status = status
        entity.token = token
        entity.data = data
        return entity
    }
}

extension UserHTTPDTO.POST.Response {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity? {
        guard let data = data else { return nil }
        let entity: AuthResponseEntity = .init(context: context)
        entity.status = status
        entity.token = token
        entity.data = data
        return entity
    }
}

extension UserHTTPDTO.PATCH.Response {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity? {
        guard let data = data else { return nil }
        let entity: AuthResponseEntity = .init(context: context)
        entity.status = status
        entity.data = data
        return entity
    }
}
