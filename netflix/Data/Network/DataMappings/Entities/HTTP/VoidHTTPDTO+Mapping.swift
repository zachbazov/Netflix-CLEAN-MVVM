//
//  VoidHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 23/03/2023.
//

import Foundation

// MARK: - VoidHTTPDTO Type

struct VoidHTTPDTO: HTTP {
    struct Request: Decodable {}
    
    struct Response: Decodable {
        let status: String
        let message: String?
    }
}

// MARK: - Mapping

extension VoidHTTPDTO.Response {
    func toDomain() -> VoidHTTP.Response {
        return .init(status: status, message: message)
    }
}
