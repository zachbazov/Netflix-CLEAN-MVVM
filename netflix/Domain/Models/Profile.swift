//
//  Profile.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - Profile Type

struct Profile {
    var _id: String?
    let name: String
    let image: String
    var active: Bool?
    var user: String?
}

// MARK: - Mapping

extension Profile {
    func toDTO() -> ProfileDTO {
        return .init(_id: _id, name: name, image: image, active: active ?? false, user: user ?? .toBlank())
    }
}

extension Array where Element == Profile {
    func toDTO() -> [ProfileDTO] {
        return map { $0.toDTO() }
    }
}
