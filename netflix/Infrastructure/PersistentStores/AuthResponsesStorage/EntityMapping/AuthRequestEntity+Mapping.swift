//
//  AuthRequestEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import CoreData

// MARK: - AuthRequestEntity + Mapping

extension AuthRequestEntity {
    func toDTO() -> UserHTTPDTO.Request {
        let userDTO = UserDTO(_id: user!._id,
                              name: user!.name,
                              email: user!.email,
                              password: user!.password,
                              passwordConfirm: user!.passwordConfirm,
                              role: user!.role,
                              active: user!.active,
                              token: user!.token,
                              mylist: user!.mylist,
                              selectedProfile: user!.selectedProfile)
        return .init(user: userDTO, selectedProfile: selectedProfile)
    }
}
