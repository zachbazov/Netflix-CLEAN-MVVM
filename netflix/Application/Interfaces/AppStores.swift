//
//  AppStores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - StoresProtocol Type

private protocol StoresOutput {
    var authResponses: AuthResponseStorage { get }
    var mediaResponses: MediaResponseStorage { get }
    var services: AppServices { get }
}

private typealias StoresProtocol = StoresOutput

// MARK: - AppStores Type

final class AppStores: StoresProtocol {
    private(set) lazy var authResponses = AuthResponseStorage(authService: services.authentication)
    private(set) lazy var mediaResponses = MediaResponseStorage()
    
    fileprivate let services: AppServices
    
    init(services: AppServices) {
        self.services = services
    }
}
