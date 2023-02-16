//
//  AppServices.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - AppServicesProtocol Type

private protocol ServicesInput {
    func createDataTransferService() -> DataTransferService
}

private protocol ServicesOutput {
    var authentication: AuthService { get }
    var dataTransfer: DataTransferService { get }
}

private typealias ServicesProtocol = ServicesInput & ServicesOutput

// MARK: - AppServices Type

final class AppServices {
    private(set) lazy var authentication = AuthService()
    private(set) lazy var dataTransfer: DataTransferService = createDataTransferService()
    
    private let configuration: AppConfiguration
    
    init(configuration: AppConfiguration = AppConfiguration()) {
        self.configuration = configuration
    }
}

// MARK: - ServicesProtocol Implementation

extension AppServices: ServicesProtocol {
    /// Allocate the service that manages the application networking.
    /// - Returns: A data transfer service object.
    fileprivate func createDataTransferService() -> DataTransferService {
        let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
        let config = NetworkConfig(baseURL: url)
        let service = NetworkService(config: config)
        return DataTransferService(networkService: service)
    }
}
