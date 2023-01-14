//
//  ListResponseDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - ListResponseDTO Type

struct ListResponseDTO {
    
    // MARK: GET Type
    
    struct GET: Decodable {
        let status: String
        var data: [ListDTO.GET]
    }
    
    // MARK: PATCH Type
    
    struct PATCH: Decodable {
        let status: String
        var data: ListDTO.POST
    }
}

// MARK: - Mapping

extension ListResponseDTO.GET {
    func toDomain() -> ListResponse.GET {
        return .init(status: status, data: data.first!.toDomain())
    }
}
