//
//  AuthRepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - AuthRepositoryEndpoints Type

protocol AuthRepositoryEndpoints {
    static func signUp(with requestDTO: UserHTTPDTO.POST.Request) -> Endpoint<UserHTTPDTO.POST.Response>
    static func signIn(with requestDTO: UserHTTPDTO.POST.Request) -> Endpoint<UserHTTPDTO.POST.Response>
    static func signOut(with request: UserHTTPDTO.GET.Request) -> Endpoint<VoidHTTP.Response>?
}
