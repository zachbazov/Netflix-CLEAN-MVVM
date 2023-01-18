//
//  AuthResponse.swift
//  netflix
//
//  Created by Zach Bazov on 08/09/2022.
//

import Foundation

// MARK: - AuthResponse Type

struct AuthResponse {
    var status: String?
    let token: String
    var data: User?
    var request: AuthRequest?
}
