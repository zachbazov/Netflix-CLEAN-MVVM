//
//  AppServices.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - AppServicesProtocol Protocol

protocol AppServicesProtocol {
    var authentication: AuthService { get }
    var dataTransfer: DataTransferService { get }
}

// MARK: - AppServices Type

final class AppServices: AppServicesProtocol {
    private(set) lazy var authentication = AuthService()
    private(set) lazy var dataTransfer: DataTransferService = createDataTransferService()
    
    private let configuration: AppConfiguration
    
    init(configuration: AppConfiguration = AppConfiguration()) {
        self.configuration = configuration
    }
}

// MARK: - Private

extension AppServices {
    /// Allocate the service that manages the application networking.
    /// - Returns: A data transfer service object.
    private func createDataTransferService() -> DataTransferService {
        let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
        let config = NetworkConfig(baseURL: url)
        let networkService = NetworkService(config: config)
        return DataTransferService(networkService: networkService)
    }
}
