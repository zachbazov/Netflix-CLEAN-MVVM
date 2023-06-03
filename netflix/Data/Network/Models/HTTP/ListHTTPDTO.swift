//
//  ListHTTPDTO.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - ListHTTPDTO Type

struct ListHTTPDTO {
    struct GET: HTTPRepresentable {
        struct Request: Decodable {
            let user: UserDTO
            var media: [MediaDTO]?
        }
        
        struct Response: Decodable {
            let status: String
            var data: [ListDTO<MediaDTO>]
        }
    }

    struct PATCH: HTTPRepresentable {
        struct Request: Decodable {
            let user: String
            let media: [String]
        }
        
        struct Response: Decodable {
            let status: String
            var data: ListDTO<String>
        }
    }
}

// MARK: - Mapping

extension ListHTTPDTO.GET.Request {
    func toDomain() -> ListHTTP.Request {
        return .init(user: user.toDomain())
    }
}

extension ListHTTPDTO.GET.Response {
    func toDomain() -> ListHTTP.Response {
        return .init(status: status, data: data.first!.toDomain())
    }
}
