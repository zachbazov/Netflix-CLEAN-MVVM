//
//  SectionHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import CoreData

// MARK: - SectionHTTPDTO Type

struct SectionHTTPDTO: HTTP {
    struct Request: Decodable {
        let user: UserDTO
    }

    struct Response: Decodable {
        let status: String
        let results: Int
        let data: [SectionDTO]
    }
}

// MARK: - Mapping

extension SectionHTTPDTO.Response {
    func toDomain() -> SectionHTTP.Response {
        return .init(status: status,
                     results: results,
                     data: data.map { $0.toDomain() })
    }
}

extension SectionHTTPDTO.Response {
    func toEntity(in context: NSManagedObjectContext) -> SectionHTTPResponseEntity {
        let authService = Application.app.services.authentication
        let entity: SectionHTTPResponseEntity = .init(context: context)
        entity.status = status
        entity.results = Int32(results)
        entity.data = data
        entity.userId = authService.user?._id
        return entity
    }
}
