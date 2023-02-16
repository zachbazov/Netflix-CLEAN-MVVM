//
//  AuthResponseEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - AuthResponseEntity + Mapping

extension AuthResponseEntity {
    func toDTO() -> UserHTTPDTO.Response? {
        guard let token = token else { return nil }
        return .init(status: status,
                     token: token,
                     data: data,
                     request: request?.toDTO())
    }
}

// MARK: - Mapping

extension UserHTTPDTO.Response {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity {
        let entity: AuthResponseEntity = .init(context: context)
        entity.status = status
        entity.token = token
        entity.data = data
        return entity
    }
}
