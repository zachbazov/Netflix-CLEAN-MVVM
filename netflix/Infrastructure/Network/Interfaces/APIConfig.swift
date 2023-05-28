//
//  APIConfig.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - APIConfig Type

struct APIConfig {
    var scheme: String = {
        guard let value = Localization.Configuration.API().scheme as String?,
              let scheme = Bundle.main.object(forInfoDictionaryKey: value) as? String else {
            let message = Localization.Configuration.API().schemeError
            fatalError(message)
        }
        
        return scheme
    }()
    
    var host: String = {
        guard let value = Localization.Configuration.API().host as String?,
              let host = Bundle.main.object(forInfoDictionaryKey: value) as? String else {
            let message = Localization.Configuration.API().hostError
            fatalError(message)
        }
        
        return host
    }()
}

// MARK: - APIConfigurable Implementation

extension APIConfig: APIConfigurable {}
