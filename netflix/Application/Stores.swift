//
//  Stores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Stores Type

final class Stores {
    lazy var userResponses: UserHTTPResponseStore = loadUserPersistentStore()
    lazy var mediaResponses = MediaHTTPResponseStore()
    lazy var sectionResponses = SectionHTTPResponseStore()
    
    private func loadUserPersistentStore() -> UserHTTPResponseStore {
        let authService = Application.app.services.auth
        return UserHTTPResponseStore(authService: authService)
    }
}
