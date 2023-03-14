//
//  UserProfile.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - UserProfile Type

struct UserProfile {
    let _id: String
    let name: String
    let image: String
    var active: Bool
    let user: String
}

// MARK: - Mapping

extension UserProfile {
    func toDTO() -> UserProfileDTO {
        return .init(_id: _id, name: name, image: image, active: active, user: user)
    }
}

extension Array where Element == UserProfile {
    func toDTO() -> [UserProfileDTO] {
        return map { $0.toDTO() }
    }
}
