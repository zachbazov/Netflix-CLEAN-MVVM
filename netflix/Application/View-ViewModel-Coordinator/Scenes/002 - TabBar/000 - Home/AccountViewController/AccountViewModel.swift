//
//  AccountViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var userUseCase: UserUseCase { get }
    var profiles: Observable<[Profile]> { get }
    var menuItems: [AccountMenuItem] { get }
}

// MARK: - AccountViewModel Type

final class AccountViewModel {
    var coordinator: AccountViewCoordinator?
    
    fileprivate lazy var userUseCase: UserUseCase = createUseCase()
    
    let profiles: Observable<[Profile]> = Observable([])
    
    lazy var menuItems: [AccountMenuItem] = createMenuItems()
}

// MARK: - ViewModel Implementation

extension AccountViewModel: ViewModel {
    func viewDidLoad() {
        loadProfiles()
    }
}

// MARK: - ViewModelProtocol Implementation

extension AccountViewModel: ViewModelProtocol {
    private func createMenuItems() -> [AccountMenuItem] {
        let list = Application.app.services.myList
        let media = list.list.toArray()
        
        let notifications = AccountMenuItem(image: "bell", title: "Notifications", options: media, isExpanded: false)
        let myList = AccountMenuItem(image: "checkmark", title: "My List")
        let appSettings = AccountMenuItem(image: "gearshape", title: "App Settings")
        let account = AccountMenuItem(image: "person", title: "Account")
        let help = AccountMenuItem(image: "questionmark.circle", title: "Help")
        let items = [notifications, myList, appSettings, account, help]
        return items
    }
    
    private func loadProfiles() {
        userProfilesDidLoad()
    }
    
    private func userProfilesDidLoad() {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let request = ProfileHTTPDTO.GET.Request(user: user)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .getUserProfiles,
            for: ProfileHTTPDTO.GET.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.profiles.value = response.data.toDomain()
                    
                    self.profiles.value.append(Profile.addProfile)
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
}

// MARK: - Private Implementation

extension AccountViewModel {
    private func createUseCase() -> UserUseCase {
        let services = Application.app.services
        let stores = Application.app.stores
        let dataTransferService = services.dataTransfer
        let persistentStore = stores.userResponses
        let repository = UserRepository(dataTransferService: dataTransferService, persistentStore: persistentStore)
        return UserUseCase(repository: repository)
    }
}
