//
//  Container.swift
//  netflix
//
//  Created by Zach Bazov on 17/02/2023.
//

import Foundation

final class Container {}

extension Container: ApplicationFactory {
    func createApplicationDependencies() -> Application.Dependencies {
        let coordinator = Coordinator()
        let services = Services()
        let stores = Stores(services: services)
        return Application.Dependencies(coordinator: coordinator,
                                        services: services,
                                        stores: stores)
    }
}
