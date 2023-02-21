//
//  Configuration.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Configuration Type

final class Configuration: APIBundleLoading {
    
    // MARK: APIBundleLoading Properties
    
    lazy var apiScheme: String = {
        guard
            let value = Localization.Configuration.API().scheme as String?,
            let scheme = Bundle.main.object(forInfoDictionaryKey: value) as? String else {
            let message = Localization.Configuration.API().schemeError
            fatalError(message)
        }
        return scheme
    }()
    
    lazy var apiHost: String = {
        guard
            let value = Localization.Configuration.API().host as String?,
            let host = Bundle.main.object(forInfoDictionaryKey: value) as? String else {
            let message = Localization.Configuration.API().hostError
            fatalError(message)
        }
        return host
    }()
}
