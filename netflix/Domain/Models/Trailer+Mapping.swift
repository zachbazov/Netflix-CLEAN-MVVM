//
//  Trailer.swift
//  netflix
//
//  Created by Zach Bazov on 12/10/2022.
//

import Foundation

// MARK: - Trailer Type

struct Trailer {
    var id: String?
    var urlPath: String
}

// MARK: - Mediable Implementation

extension Trailer: Mediable {}

// MARK: - Mapping

extension Array where Element == String {
    func toDomain() -> [Trailer] {
        return map { .init(urlPath: $0) }
    }
}
