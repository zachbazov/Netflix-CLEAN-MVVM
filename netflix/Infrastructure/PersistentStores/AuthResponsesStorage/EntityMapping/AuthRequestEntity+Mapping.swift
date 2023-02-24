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
                              mylist: user!.mylist)
        return .init(user: userDTO)
    }
}

extension UserHTTPDTO.Request {
    func toEntity(in context: NSManagedObjectContext) -> AuthRequestEntity {
        let entity: AuthRequestEntity = .init(context: context)
        entity.user?._id = user._id
        entity.user?.name = user.name
        entity.user?.email = user.email
        entity.user?.password = user.password
        entity.user?.passwordConfirm = user.passwordConfirm
        entity.user?.role = user.role
        entity.user?.active = user.active
        return entity
    }
}
