//
//  Stores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - StoresProtocol Type

private protocol StoresOutput {
    var authResponses: AuthResponseStorage { get }
    var mediaResponses: MediaResponseStorage { get }
    var services: Services { get }
}

private typealias StoresProtocol = StoresOutput

// MARK: - Stores Type

final class Stores: StoresProtocol {
    private(set) lazy var authResponses = AuthResponseStorage(authService: services.authentication)
    private(set) lazy var mediaResponses = MediaResponseStorage()
    
    fileprivate let services: Services
    
    init(services: Services) {
        self.services = services
    }
}
