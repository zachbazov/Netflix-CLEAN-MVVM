//
//  User.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - User Type

struct User {
    var _id: String?
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirm: String?
    var role: String?
    var active: Bool?
    var token: String?
    var mylist: [String]?
    var profiles: [String]?
    var selectedProfile: String?
}

// MARK: - Mapping

extension User {
    func toDTO() -> UserDTO {
        return .init(_id: _id,
                     name: name,
                     email: email,
                     password: password,
                     passwordConfirm: passwordConfirm,
                     role: role,
                     active: active,
                     token: token,
                     mylist: mylist,
                     profiles: profiles,
                     selectedProfile: selectedProfile)
    }
}
