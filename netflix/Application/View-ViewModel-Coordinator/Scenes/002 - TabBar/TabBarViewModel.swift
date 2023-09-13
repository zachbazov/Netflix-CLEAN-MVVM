//
//  TabBarViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - TabBarViewModel Type

final class TabBarViewModel {
    var coordinator: TabBarCoordinator?
    
    private(set) lazy var userUseCase: UserUseCase = createUserUseCase()
    
    let selectedProfile: Observable<Profile?> = Observable(nil)
}

// MARK: - ViewModel Implementation

extension TabBarViewModel: ViewModel {}

// MARK: - CoordinatorAssignable Implementation

extension TabBarViewModel: CoordinatorAssignable {}

// MARK: - Internal Implementation

extension TabBarViewModel {
    private func createUserUseCase() -> UserUseCase {
        let services = Application.app.services
        let stores = Application.app.stores
        let dataTransferService = services.dataTransfer
        let userResponseStorage = stores.userResponses
        let userRepository = UserRepository(dataTransferService: dataTransferService, persistentStore: userResponseStorage)
        return UserUseCase(repository: userRepository)
    }
    
    func getSelectedProfile(_ completion: (() -> Void)?) {
        let authService = Application.app.services.auth
        
        guard let user = authService.user,
              let selectedProfileId = user.selectedProfile
        else { return }
        
        let request = ProfileHTTPDTO.GET.Request(user: user, _id: selectedProfileId)
        
        userUseCase.repository.task = userUseCase.request(endpoint: .getUserProfiles,
                                                          for: ProfileHTTPDTO.GET.Response.self,
                                                          request: request,
                                                          cached: { _ in },
                                                          completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.selectedProfile.value = response.data.first?.toDomain()
                
                completion?()
            case .failure(let error):
                printIfDebug(.debug, "\(error)")
            }
        })
    }
}
