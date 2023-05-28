//
//  DependencyRegistry.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - RegistrableDepedency Type

private protocol RegistrableDepedency {
    func register<T>(_ type: T.Type, handler: @escaping (DependencyResolver) -> T)
    func resolve<T>(_ type: T.Type, resolver: DependencyResolver) -> T
}

// MARK: - DependencyRegistry Type

final class DependencyRegistry {
    var dependencies: [String: Any] = [:]
}

// MARK: - RegistrableDepedency Implementation

extension DependencyRegistry: RegistrableDepedency {
    func register<T>(_ type: T.Type, handler: @escaping (DependencyResolver) -> T) {
        let key = String(describing: type)
        
        dependencies[key] = handler
    }
    
    func resolve<T>(_ type: T.Type, resolver: DependencyResolver) -> T {
        let key = String(describing: type)
        
        guard let factory = dependencies[key] as? (DependencyResolver) -> T else {
            fatalError("Dependency `\(key)` not registered.")
        }
        
        return factory(resolver)
    }
}
