//
//  APIConfig.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - APIConfigurable Type

private protocol APIConfigurable {
    var scheme: String { get }
    var host: String { get }
}

// MARK: - APIConfig Type

final class APIConfig: APIConfigurable {
    fileprivate var scheme: String = {
        guard let value = Localization.Configuration.API().scheme as String?,
              let scheme = Bundle.main.object(forInfoDictionaryKey: value) as? String else {
            let message = Localization.Configuration.API().schemeError
            fatalError(message)
        }
        
        return scheme
    }()
    
    fileprivate var host: String = {
        guard let value = Localization.Configuration.API().host as String?,
              let host = Bundle.main.object(forInfoDictionaryKey: value) as? String else {
            let message = Localization.Configuration.API().hostError
            fatalError(message)
        }
        
        return host
    }()
    
    var urlString: String {
        return scheme + "://" + host
    }
}
