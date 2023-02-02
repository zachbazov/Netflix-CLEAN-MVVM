//
//  SectionHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - SectionHTTPDTO Type

struct SectionHTTPDTO: HTTP {
    
    typealias Request = Void

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
