//
//  ProfileViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var userUseCase: UserUseCase { get }
    
    var profiles: [UserProfile] { get }
    var selectedProfile: UserProfile? { get }
    
    func getUserProfiles()
    func createUserProfile()
    func updateUserProfile(with profileId: String)
    
    func userProfilesDidLoad() async
    func userProfileDidCreate() async
    func userProfileDidUpdate(with profileId: String) async
    
    func didFinish()
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - ProfileViewModel Type

final class ProfileViewModel {
    var coordinator: ProfileCoordinator?
    
    fileprivate lazy var userUseCase = UserUseCase()
    
    var profiles = [UserProfile]()
    var selectedProfile: UserProfile?
    
    deinit {
        print("deinit \(String(describing: Self.self))")
        selectedProfile = nil
        coordinator = nil
    }
}

// MARK: - ViewModel Implementation

extension ProfileViewModel: ViewModel {
    func viewDidLoad() {
        loadData()
    }
}

// MARK: - ViewModelProtocol Implementation

extension ProfileViewModel: ViewModelProtocol {
    fileprivate func getUserProfiles() {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.GET.Request(user: user)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .getUserProfiles,
            for: UserProfileHTTPDTO.GET.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.profiles = response.data.toDomain()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func userProfilesDidLoad() async {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.GET.Request(user: user)
        let response = await userUseCase.request(endpoint: .getUserProfiles, for: UserProfileHTTPDTO.GET.Response.self, request: request)
        
        guard let profiles = response?.data.toDomain() else { return }
        
        self.profiles = profiles
        
        let addProfile = UserProfile(_id: "", name: "Add Profile", image: "plus", active: false, user: user._id!)
        
        self.profiles.append(addProfile)
    }
    
    fileprivate func createUserProfile() {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let profile = UserProfileDTO(name: "test", image: "av-dark-green", active: false, user: user._id ?? "")
        let request = UserProfileHTTPDTO.POST.Request(user: user, profile: profile)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .createUserProfile,
            for: UserProfileHTTPDTO.POST.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else {return }
                switch result {
                case .success(let response):
                    self.selectedProfile = response.data.toDomain()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func userProfileDidCreate() async {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let profile = UserProfileDTO(name: "test", image: "av-dark-green", active: false, user: user._id ?? "")
        let request = UserProfileHTTPDTO.POST.Request(user: user, profile: profile)
        
        let response = await userUseCase.request(endpoint: .createUserProfile, for: UserProfileHTTPDTO.POST.Response.self, request: request)
        
        guard let response = response else { return }
        
        self.selectedProfile = response.data.toDomain()
    }
    
    func updateUserProfile(with profileId: String) {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserHTTPDTO.PATCH.Request(user: user, selectedProfile: profileId)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .updateUserData,
            for: UserHTTPDTO.PATCH.Response.self,
            request: request,
            cached: { _ in },
            completion: { result in
                switch result {
                case .success:
                    mainQueueDispatch {
                        let coordinator = Application.app.coordinator
                        coordinator.coordinate(to: .tabBar)
                    }
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func updateUserProfileForSigningOut(with profileId: String, completion: @escaping () -> Void) {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserHTTPDTO.PATCH.Request(user: user, selectedProfile: profileId)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .updateUserData,
            for: UserHTTPDTO.PATCH.Response.self,
            request: request,
            cached: { _ in },
            completion: { result in
                switch result {
                case .success:
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func updateUserProfileForSigningOut() async -> Bool {
        let authService = Application.app.services.authentication
        let authResponses = Application.app.stores.authResponses
        
        guard let user = authService.user else { return false }
        
        let request = UserHTTPDTO.PATCH.Request(user: user, selectedProfile: nil)
        
        let response = await userUseCase.request(endpoint: .updateUserData, for: UserHTTPDTO.PATCH.Response.self, request: request)
        
        guard let response = response else { return false }
        
        authResponses.save(response: response, for: request)
        
        return true
    }
    
    func userProfileDidUpdate(with profileId: String) async {
        let authService = Application.app.services.authentication
        let authResponses = Application.app.stores.authResponses
        
        guard let user = authService.user else { return }
        
        let request = UserHTTPDTO.PATCH.Request(user: user, selectedProfile: profileId)
        
        let response = await userUseCase.request(endpoint: .updateUserData, for: UserHTTPDTO.PATCH.Response.self, request: request)
        
        guard let response = response else { return }
        
        authResponses.save(response: response, for: request)
        
        mainQueueDispatch {
            let coordinator = Application.app.coordinator
            coordinator.coordinate(to: .tabBar)
        }
    }
    
    fileprivate func didFinish() {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            guard let dataSource = self.coordinator?.userProfileController.dataSource else { return }
            dataSource.dataSourceDidChange()
        }
    }
}

// MARK: - Private UI Implementation

extension ProfileViewModel {
    private func loadData() {
        if #available(iOS 13.0, *) {
            return awaitLoading()
        }
        
        getUserProfiles()
        
        didFinish()
    }
    
    private func awaitLoading() {
        Task {
            await userProfilesDidLoad()
            
            didFinish()
        }
    }
}