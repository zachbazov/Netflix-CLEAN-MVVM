//
//  Stores.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Stores Type

final class Stores {
    private let dependencies: DI = DI.shared
    
    lazy var userResponses: UserHTTPResponseStore = dependencies.resolve(UserHTTPResponseStore.self)
    lazy var mediaResponses: MediaHTTPResponseStore = dependencies.resolve(MediaHTTPResponseStore.self)
    lazy var sectionResponses: SectionHTTPResponseStore = dependencies.resolve(SectionHTTPResponseStore.self)
}
