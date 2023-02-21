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
    var authResponses: AuthResponseStorage { get }
    var mediaResponses: MediaResponseStorage { get }
}

private typealias StoresProtocol = StoresOutput

// MARK: - Stores Type

final class Stores: StoresProtocol {
    fileprivate let services: Services
    
    lazy var authResponses = AuthResponseStorage(authService: services.authentication)
    lazy var mediaResponses = MediaResponseStorage()
    
    required init(services: Services) {
        self.services = services
    }
}
