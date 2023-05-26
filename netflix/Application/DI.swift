//
//  DI.swift
//  netflix
//
//  Created by Zach Bazov on 26/05/2023.
//

import Foundation

//

protocol InversableDependency {
    
}

// MARK: - DI Type

final class DI {
    static let shared = DI()
    
    private let useCase: UseCaseDI
    
    private init() {
        self.useCase = UseCaseDI()
    }
    
    func useCases() -> UseCaseDI {
        return useCase
    }
}

//

protocol UseCaseDependencyInversing {
    func createUserUseCase() -> UserUseCase
    func createSectionUseCase() -> SectionUseCase
    func createMediaUseCase() -> MediaUseCase
    func createSeasonUseCase() -> SeasonUseCase
    func createListUseCase() -> ListUseCase
}

final class UseCaseDI {}

extension UseCaseDI: UseCaseDependencyInversing {
    func createUserUseCase() -> UserUseCase {
        let services = Application.app.services
        let authService = services.authentication
        let dataTransferService = services.dataTransfer
        let persistentStore = UserHTTPResponseStore(authService: authService)
        let authenticator = UserRepositoryAuthenticator(dataTransferService: dataTransferService, persistentStore: persistentStore)
        let invoker = RepositoryInvoker(dataTransferService: dataTransferService, persistentStore: persistentStore)
        let repository = UserRepository(dataTransferService: dataTransferService, authenticator: authenticator, persistentStore: persistentStore, invoker: invoker)
        return UserUseCase(repository: repository)
    }
    
    func createSectionUseCase() -> SectionUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = SectionRepository(dataTransferService: dataTransferService)
        return SectionUseCase(repository: repository)
    }
    
    func createMediaUseCase() -> MediaUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = MediaRepository(dataTransferService: dataTransferService)
        return MediaUseCase(repository: repository)
    }
    
    func createSeasonUseCase() -> SeasonUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = SeasonRepository(dataTransferService: dataTransferService)
        return SeasonUseCase(repository: repository)
    }
    
    func createListUseCase() -> ListUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = ListRepository(dataTransferService: dataTransferService)
        return ListUseCase(repository: repository)
    }
}

//
