//
//  AuthRepository+Endpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - AuthRepositoryEndpoints Protocol

protocol AuthRepositoryEndpoints {
    static func signUp(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signIn(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signOut() -> Endpoint<Void>
}
