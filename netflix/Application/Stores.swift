//
//  Stores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - StoresProtocol Type

private protocol StoresProtocol {
    var services: Services { get }
    var userResponses: UserHTTPResponseStore { get }
    var mediaResponses: MediaHTTPResponseStore { get }
}

// MARK: - Stores Type

final class Stores: StoresProtocol {
    fileprivate let services: Services
    
    lazy var userResponses = UserHTTPResponseStore(authService: services.authentication)
    lazy var mediaResponses = MediaHTTPResponseStore()
    lazy var sectionResponses = SectionHTTPResponseStore()
    
    required init(services: Services) {
        self.services = services
    }
}
