//
//  AuthRequestEntity+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import CoreData

// MARK: - AuthRequestEntity + Mapping

extension AuthRequestEntity {
    func toDTO() -> UserHTTPDTO.POST.Request {
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
        return .init(user: userDTO)
    }
}

extension UserHTTPDTO.POST.Request {
    func toEntity(in context: NSManagedObjectContext) -> AuthRequestEntity {
        let entity: AuthRequestEntity = .init(context: context)
        entity.user?._id = user._id
        entity.user?.name = user.name
        entity.user?.email = user.email
        entity.user?.password = user.password
        entity.user?.passwordConfirm = user.passwordConfirm
        entity.user?.role = user.role
        entity.user?.active = user.active
        entity.user?.token = user.token
        entity.user?.selectedProfile = user.selectedProfile
        return entity
    }
}

extension AuthRequestEntity {
    func toDTO() -> UserHTTPDTO.PATCH.Request {
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
        return .init(user: userDTO, selectedProfile: userDTO.selectedProfile!)
    }
}

extension UserHTTPDTO.PATCH.Request {
    func toEntity(in context: NSManagedObjectContext) -> AuthRequestEntity {
        let entity: AuthRequestEntity = .init(context: context)
        entity.user?._id = user._id
        entity.user?.name = user.name
        entity.user?.email = user.email
        entity.user?.password = user.password
        entity.user?.passwordConfirm = user.passwordConfirm
        entity.user?.role = user.role
        entity.user?.active = user.active
        entity.user?.token = user.token
        return entity
    }
}
