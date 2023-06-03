//
//  VoidHTTPDTO.swift
//  netflix
//
//  Created by Zach Bazov on 23/03/2023.
//

import Foundation

// MARK: - VoidHTTPDTO Type

struct VoidHTTPDTO: HTTPRepresentable {
    struct Request: Decodable {}
    
    struct Response: Decodable {
        let status: String
        var message: String?
    }
}

// MARK: - Mapping

extension VoidHTTPDTO.Response {
    func toDomain() -> VoidHTTP.Response {
        return .init(status: status, message: message)
    }
}
