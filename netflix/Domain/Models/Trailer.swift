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
    let urlPath: String
}

// MARK: - MediaRepresentable Implementation

extension Trailer: MediaRepresentable {}

// MARK: - Mapping

extension Array where Element == String {
    func toDomain() -> [Trailer] {
        return map { .init(urlPath: $0) }
    }
}
