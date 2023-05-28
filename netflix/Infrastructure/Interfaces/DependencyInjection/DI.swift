//
//  DI.swift
//  netflix
//
//  Created by Zach Bazov on 26/05/2023.
//

import Foundation

// MARK: - ApplicationDepending Type

private protocol ApplicationDepending {
    func registerCoordinators()
    func registerAppServices()
    func registerStores()
    func registerConfigurators()
}

// MARK: - DomainDepending Type

private protocol DomainDepending {
    func registerUseCases()
}

// MARK: - InfrastructureDepending Type

private protocol InfrastructureDepending {
    func registerServices()
}

// MARK: - DI Type

final class DI {
    static let shared = DI()

    lazy var registry = DependencyRegistry()
    lazy var resolver = DependencyResolver(registry: registry)

    private init() {
        registerConfigurators()
        registerViewModels()
        registerViewControllers()
        registerServices()
        registerStores()
        registerAppServices()
        registerUseCases()
        registerCoordinators()
    }
}

// MARK: - ResolvableDependency Implementation

extension DI: ResolvableDependency {
    func resolve<T>(_ type: T.Type) -> T {
        return resolver.resolve(type)
    }
}

// MARK: - ApplicationDepending Implementation

extension DI: ApplicationDepending {
    fileprivate func registerConfigurators() {
        registry.register(Configuration.self) { _ in
            return Configuration()
        }
        
        registry.register(APIConfig.self) { _ in
            return APIConfig()
        }
    }
    
    fileprivate func registerViewModels() {
        registry.register(AuthViewModel.self) { _ in
            return AuthViewModel()
        }
        
        registry.register(ProfileViewModel.self) { _ in
            return ProfileViewModel()
        }
        
        registry.register(TabBarViewModel.self) { _ in
            return TabBarViewModel()
        }
    }
    
    fileprivate func registerViewControllers() {
        registry.register(AuthController.self) { _ in
            return AuthController()
        }
        
        registry.register(ProfileController.self) { _ in
            return ProfileController()
        }
        
        registry.register(TabBarController.self) { _ in
            return TabBarController()
        }
    }
    
    fileprivate func registerAppServices() {
        registry.register(Services.self) { _ in
            return Services()
        }
    }
    
    fileprivate func registerStores() {
        registry.register(Stores.self) { resolver in
            return Stores()
        }
        
        registry.register(UserHTTPResponseStore.self) { resolver in
            let authService = resolver.resolve(AuthService.self)
            return UserHTTPResponseStore(authService: authService)
        }
        
        registry.register(MediaHTTPResponseStore.self) { _ in
            return MediaHTTPResponseStore()
        }
        
        registry.register(SectionHTTPResponseStore.self) { _ in
            return SectionHTTPResponseStore()
        }
    }
    
    fileprivate func registerCoordinators() {
        registry.register(RootCoordinator.self) { _ in
            return RootCoordinator()
        }
        
        registry.register(AuthCoordinator.self) { resolver in
            let viewModel = resolver.resolve(AuthViewModel.self)
            let controller = resolver.resolve(AuthController.self)
            let coordinator = AuthCoordinator()
            coordinator.viewController = controller
            viewModel.coordinator = coordinator
            controller.viewModel = viewModel
            return coordinator
        }
        
        registry.register(ProfileCoordinator.self) { resolver in
            let controller = resolver.resolve(ProfileController.self)
            let viewModel = resolver.resolve(ProfileViewModel.self)
            let coordinator = ProfileCoordinator()
            coordinator.viewController = controller
            viewModel.coordinator = coordinator
            controller.viewModel = viewModel
            return coordinator
        }
        
        registry.register(TabBarCoordinator.self) { resolver in
            let controller = resolver.resolve(TabBarController.self)
            let viewModel = resolver.resolve(TabBarViewModel.self)
            let coordinator = TabBarCoordinator()
            coordinator.viewController = controller
            viewModel.coordinator = coordinator
            controller.viewModel = viewModel
            return coordinator
        }
    }
}

// MARK: - DomainDepending Implementation

extension DI: DomainDepending {
    fileprivate func registerUseCases() {
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

// MARK: - InfrastructureDepending Implementation

extension DI: InfrastructureDepending {
    fileprivate func registerServices() {
        registry.register(AuthService.self) { _ in
            return AuthService()
        }
        
        registry.register(DataTransferService.self) { resolver in
            let networkService = resolver.resolve(NetworkService.self)
            return DataTransferService(networkService: networkService)
        }
        
        registry.register(NetworkService.self) { resolver in
            var configuration = Application.app.configuration
            let url = URL(string: configuration.api.scheme + "://" + configuration.api.host)!
            let config = NetworkConfig(baseURL: url)
            return NetworkService(config: config)
        }
    }
}
