//
//  Profile+Extension.swift
//  netflix
//
//  Created by Developer on 23/08/2023.
//

import Foundation

// MARK: - Profile + Add Profile

extension Profile {
    static var addProfile: Profile {
        let authService = Application.app.services.auth
        
        guard let user = authService.user,
              let userId = user._id
        else { fatalError("Unexpected user credentials.") }
        
        return Profile(_id: "addProfile", name: "Add Profile", image: "plus", active: false, user: userId)
    }
}
