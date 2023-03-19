//
//  AccountViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    
}

private protocol ViewModelOutput {
    
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - AccountViewModel Type

final class AccountViewModel {
    var coordinator: AccountViewCoordinator?
    
    fileprivate lazy var userUseCase = UserUseCase()
    
    let profiles: Observable<[UserProfile]> = .init([])
    lazy var menuItems: [AccountMenuItem] = createMenuItems()
    private(set) var profileItems = [ProfileItem]()
    
    private func createMenuItems() -> [AccountMenuItem] {
        let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as? HomeViewController
        let media = homeViewController!.viewModel.myList.viewModel.list.value.toArray()
        
        let notifications = AccountMenuItem(image: "bell", title: "Notifications", options: media, isExpanded: false)
        let myList = AccountMenuItem(image: "checkmark", title: "My List")
        let appSettings = AccountMenuItem(image: "gearshape", title: "App Settings")
        let account = AccountMenuItem(image: "person", title: "Account")
        let help = AccountMenuItem(image: "questionmark.circle", title: "Help")
        let items = [notifications, myList, appSettings, account, help]
        return items
    }
    
    fileprivate func getUserProfiles() {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.GET.Request(user: user)
        
        userUseCase.repository.task = userUseCase.request(
            for: UserProfileHTTPDTO.GET.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.profiles.value = response.data.toDomain()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func userProfilesDidLoad() async {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.GET.Request(user: user)
        let response = await userUseCase.request(for: UserProfileHTTPDTO.GET.Response.self, request: request)
        
        guard let profiles = response?.data.toDomain() else { return }
        
        self.profiles.value = profiles
        
        let addProfile = UserProfile(_id: "add", name: "Add Profile", image: "plus", active: false, user: user._id!)
        
        self.profiles.value.append(addProfile)
    }
}

// MARK: - ViewModel Implementation

extension AccountViewModel: ViewModel {
    func viewDidLoad() {
        loadData()
    }
    
    private func loadData() {
        if #available(iOS 13.0, *) {
            Task {
                await userProfilesDidLoad()
            }
            
            return
        }
        
        getUserProfiles()
    }
}

// MARK: - ViewModelProtocol Implementation

extension AccountViewModel: ViewModelProtocol {}
