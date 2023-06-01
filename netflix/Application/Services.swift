//
//  Services.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Services Type

final class Services {
    lazy var auth = AuthService()
    lazy var dataTransfer: DataTransferService = createDataTransferService()
    lazy var myList = MyList()
    
    private func createDataTransferService() -> DataTransferService {
        var configuration = Application.app.configuration
        
        guard let url = URL(string: configuration.api.urlString) else { fatalError() }
        
        let config = NetworkConfig(baseURL: url)
        let networkService = NetworkService(config: config)
        return DataTransferService(networkService: networkService)
    }
}
