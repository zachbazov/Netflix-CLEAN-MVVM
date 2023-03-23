//
//  Services.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - ServicesProtocol Type

private protocol ServicesProtocol {
    var configuration: Configuration { get }
    var authentication: AuthService { get }
    var dataTransfer: DataTransferService { get }
    
    func createDataTransferService() -> DataTransferService
}

// MARK: - Services Type

final class Services {
    fileprivate let configuration: Configuration
    
    lazy var authentication = AuthService()
    lazy var dataTransfer: DataTransferService = createDataTransferService()
    
    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
}

// MARK: - ServicesProtocol Implementation

extension Services: ServicesProtocol {
    /// Allocate the service that manages the application networking.
    /// - Returns: A data transfer service object.
    func createDataTransferService() -> DataTransferService {
        let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
        let config = NetworkConfig(baseURL: url)
        let service = NetworkService(config: config)
        return DataTransferService(networkService: service)
    }
}
