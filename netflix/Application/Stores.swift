//
//  Stores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - StoresProtocol Type

private protocol StoresOutput {
    var services: Services { get }
    var userResponses: UserResponseStore { get }
    var mediaResponses: MediaHTTPResponseStore { get }
}

private typealias StoresProtocol = StoresOutput

// MARK: - Stores Type

final class Stores: StoresProtocol {
    fileprivate let services: Services
    
    lazy var userResponses = UserResponseStore(authService: services.authentication)
    lazy var mediaResponses = MediaHTTPResponseStore()
    
    required init(services: Services) {
        self.services = services
    }
}
