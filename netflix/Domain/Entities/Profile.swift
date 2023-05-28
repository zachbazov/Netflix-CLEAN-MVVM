//
//  Profile.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - Profile Type

struct Profile {
    var _id: String? = nil
    let name: String
    let image: String
    var active: Bool?
    let user: String?
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
