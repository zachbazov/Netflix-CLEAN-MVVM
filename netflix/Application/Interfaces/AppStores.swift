//
//  AppStores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - AppStoresProtocol Protocol

protocol AppStoresProtocol {
    var authResponses: AuthResponseStorage { get }
    var mediaResponses: MediaResponseStorage { get }
}

// MARK: - AppStores Type

final class AppStores: AppStoresProtocol {
    private(set) lazy var authResponses = AuthResponseStorage(authService: services.authentication)
    private(set) lazy var mediaResponses = MediaResponseStorage()
    
    private let services: AppServices
    
    init(services: AppServices) {
        self.services = services
    }
}
