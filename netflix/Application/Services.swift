//
//  Services.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Services Type

final class Services {
    let configuration: Configuration
    
    lazy var authentication: AuthService = DI.shared.resolve(AuthService.self)
    lazy var dataTransfer: DataTransferService = DI.shared.resolve(DataTransferService.self)
    
    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
}
