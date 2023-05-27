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
    
    lazy var authentication: AuthService = AuthService()
    lazy var dataTransfer: DataTransferService = createDataTransferService()
    
    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
}

// MARK: - Private Implementation

extension Services {
    private func createDataTransferService() -> DataTransferService {
        let configuration = Application.app.services.configuration
        let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
        let config = NetworkConfig(baseURL: url)
        let networkService = NetworkService(config: config)
        return DataTransferService(networkService: networkService)
    }
}
