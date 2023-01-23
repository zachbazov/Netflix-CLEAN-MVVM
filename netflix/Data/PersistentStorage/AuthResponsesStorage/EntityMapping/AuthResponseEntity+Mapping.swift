//
//  AuthResponseEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - AuthResponseEntity + Mapping

extension AuthResponseEntity {
    func toDTO() -> AuthResponseDTO? {
        guard let token = token else { return nil }
        return .init(token: token,
                     data: data,
                     request: request?.toDTO())
    }
}

// MARK: - Mapping

extension AuthResponseDTO {
    func toEntity(in context: NSManagedObjectContext) -> AuthResponseEntity {
        let entity: AuthResponseEntity = .init(context: context)
        entity.token = token
        entity.data = data
        return entity
    }
}
