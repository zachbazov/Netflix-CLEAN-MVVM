//
//  Configuration.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import Foundation

// MARK: - Configuration Type

struct Configuration {
    private let dependencies: DI = DI.shared
    
    lazy var api: APIConfig = dependencies.resolve(APIConfig.self)
}
