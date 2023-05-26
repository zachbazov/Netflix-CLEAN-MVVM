//
//  DI.swift
//  netflix
//
//  Created by Zach Bazov on 26/05/2023.
//

import Foundation

protocol RegistrableDepedency {
    func register<T>(_ type: T.Type, handler: @escaping (DependencyResolver) -> T)
    func resolve<T>(_ type: T.Type, resolver: DependencyResolver) -> T
}

protocol ResolvableDependency {
    func resolve<T>(_ type: T.Type) -> T
}

final class DependencyRegistry {
    var dependencies: [String: Any] = [:]
}

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

final class DependencyResolver {
    private let registry: DependencyRegistry
    
    init(registry: DependencyRegistry) {
        self.registry = registry
    }
}

extension DependencyResolver: ResolvableDependency {
    func resolve<T>(_ type: T.Type) -> T {
        return registry.resolve(type, resolver: self)
    }
}

final class DI {
    static let shared = DI()

    lazy var registry = DependencyRegistry()
    lazy var resolver = DependencyResolver(registry: registry)

    private init() {
        registerServices()
        registerUseCases()
    }
}

extension DI: ResolvableDependency {
    func resolve<T>(_ type: T.Type) -> T {
        return resolver.resolve(type)
    }
}

protocol ApplicationDepending {
    
}

protocol DomainDepending {
    func registerUseCases()
}

protocol InfrastructureDepending {
    func registerServices()
}

extension DI: InfrastructureDepending {
    func registerServices() {
        registry.register(AuthService.self) { _ in
            return AuthService()
        }
        
        registry.register(DataTransferService.self) { resolver in
            let networkService = resolver.resolve(NetworkService.self)
            return DataTransferService(networkService: networkService)
        }
        
        registry.register(NetworkService.self) { resolver in
            let configuration = Application.app.services.configuration
            let url = URL(string: configuration.apiScheme + "://" + configuration.apiHost)!
            let config = NetworkConfig(baseURL: url)
            return NetworkService(config: config)
        }
    }
}

extension DI: DomainDepending {
    func registerUseCases() {
        registry.register(UserUseCase.self) { resolver in
            let authService = resolver.resolve(AuthService.self)
            let dataTransferService = resolver.resolve(DataTransferService.self)
            let persistentStore = UserHTTPResponseStore(authService: authService)
            let authenticator = UserRepositoryAuthenticator(dataTransferService: dataTransferService, persistentStore: persistentStore)
            let invoker = RepositoryInvoker(dataTransferService: dataTransferService, persistentStore: persistentStore)
            let repository = UserRepository(dataTransferService: dataTransferService, authenticator: authenticator, persistentStore: persistentStore, invoker: invoker)
            return UserUseCase(repository: repository)
        }
        
        registry.register(SectionUseCase.self) { resolver in
            let dataTransferService = resolver.resolve(DataTransferService.self)
            let repository = SectionRepository(dataTransferService: dataTransferService)
            return SectionUseCase(repository: repository)
        }
        
        registry.register(MediaUseCase.self) { resolver in
            let dataTransferService = resolver.resolve(DataTransferService.self)
            let repository = MediaRepository(dataTransferService: dataTransferService)
            return MediaUseCase(repository: repository)
        }
        
        registry.register(SeasonUseCase.self) { resolver in
            let dataTransferService = resolver.resolve(DataTransferService.self)
            let repository = SeasonRepository(dataTransferService: dataTransferService)
            return SeasonUseCase(repository: repository)
        }
        
        registry.register(ListUseCase.self) { resolver in
            let dataTransferService = resolver.resolve(DataTransferService.self)
            let repository = ListRepository(dataTransferService: dataTransferService)
            return ListUseCase(repository: repository)
        }
    }
}
