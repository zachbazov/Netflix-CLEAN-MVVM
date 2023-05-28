//
//  DependencyResolver.swift
//  netflix
//
//  Created by Zach Bazov on 28/05/2023.
//

import Foundation

// MARK: - ResolvableDependency Type

protocol ResolvableDependency {
    func resolve<T>(_ type: T.Type) -> T
}

// MARK: - DependencyResolver Type

final class DependencyResolver {
    let registry: DependencyRegistry
    
    init(registry: DependencyRegistry) {
        self.registry = registry
    }
}

// MARK: - DependencyResolver Implementation

extension DependencyResolver: ResolvableDependency {
    func resolve<T>(_ type: T.Type) -> T {
        return registry.resolve(type, resolver: self)
    }
}
