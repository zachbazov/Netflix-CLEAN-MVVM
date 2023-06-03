//
//  MediaHTTPDTO.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import CoreData

// MARK: - MediaHTTPDTO Type

struct MediaHTTPDTO: HTTPRepresentable {
    struct Request: Decodable {
        var id: String?
        var slug: String?
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
    
    func toEntity(in context: NSManagedObjectContext) -> MediaHTTPResponseEntity {
        let entity: MediaHTTPResponseEntity = .init(context: context)
        entity.status = status
        entity.results = Int32(results)
        entity.data = data
        return entity
    }
}
