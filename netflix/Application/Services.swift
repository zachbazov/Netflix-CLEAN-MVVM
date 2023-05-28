//
//  Services.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Services Type

final class Services {
    private let dependencies: DI = DI.shared
    
    lazy var auth: AuthService = dependencies.resolve(AuthService.self)
    lazy var dataTransfer: DataTransferService = dependencies.resolve(DataTransferService.self)
}
