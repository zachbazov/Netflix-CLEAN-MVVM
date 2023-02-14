//
//  MediaHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import CoreData

// MARK: - MediaHTTPDTO Type

struct MediaHTTPDTO: HTTP {
    struct Request: Decodable {
        let id: String?
        let slug: String?
    }
    
    struct Response: Codable {
        let status: String
        let results: Int
        let data: [MediaDTO]
    }
}

// MARK: - Mapping

extension MediaHTTPDTO.Response {
    func toDomain() -> MediaHTTP.Response {
        return .init(status: status,
                     results: results,
                     data: data.map { $0.toDomain() })
    }
    
    func toEntity(in context: NSManagedObjectContext) -> MediaResponseEntity {
        let entity: MediaResponseEntity = .init(context: context)
        entity.status = status
        entity.results = Int32(results)
        entity.data = data
        return entity
    }
}
