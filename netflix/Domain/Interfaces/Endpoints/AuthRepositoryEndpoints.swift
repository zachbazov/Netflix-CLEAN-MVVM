//
//  AuthRepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - AuthRepositoryEndpoints Type

protocol AuthRepositoryEndpoints {
    static func signUp(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signIn(with requestDTO: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response>
    static func signOut(with request: UserHTTPDTO.Request) -> Endpoint<Void>?
}
