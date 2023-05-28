//
//  ProfileViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var userUseCase: UserUseCase { get }
    
    var profiles: [Profile] { get }
    var selectedProfile: Profile? { get }
    
    func getUserProfiles()
    func createUserProfile()
    func updateUserProfile(with profileId: String)
    func updateUserProfileForSigningOut(completion: @escaping () -> Void)
    
    func userProfilesDidLoad() async
    func userProfileDidCreate() async
    func userProfileDidUpdate(with profileId: String) async
    func updateUserProfileForSigningOut() async -> Bool
    
    func didFinish()
}

// MARK: - ProfileViewModel Type

final class ProfileViewModel {
    var coordinator: ProfileCoordinator?
    
    fileprivate(set) lazy var userUseCase: UserUseCase = createUseCase()
    
    var profiles = [Profile]()
    var selectedProfile: Profile?
    
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
                    self.profiles = response.data.toDomain()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func createUserProfile() {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let profile = ProfileDTO(name: "test", image: "av-dark-green", active: false, user: user._id ?? "")
        let request = ProfileHTTPDTO.POST.Request(user: user, profile: profile)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .createUserProfile,
            for: ProfileHTTPDTO.POST.Response.self,
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
    
    func updateUserProfile(with profileId: String) {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let request = UserHTTPDTO.Request(user: user, selectedProfile: profileId)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .updateUserData,
            for: UserHTTPDTO.Response.self,
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
    
    func updateUserProfileForSigningOut(completion: @escaping () -> Void) {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let request = UserHTTPDTO.Request(user: user, selectedProfile: nil)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .updateUserData,
            for: UserHTTPDTO.Response.self,
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
    
    fileprivate func userProfilesDidLoad() async {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let request = ProfileHTTPDTO.GET.Request(user: user)
        let response = await userUseCase.request(endpoint: .getUserProfiles, for: ProfileHTTPDTO.GET.Response.self, request: request)
        
        guard let profiles = response?.data.toDomain() else { return }
        
        self.profiles = profiles
        
        let addProfile = Profile(_id: "", name: "Add Profile", image: "plus", active: false, user: user._id!)
        
        self.profiles.append(addProfile)
    }
    
    fileprivate func userProfileDidCreate() async {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let profile = ProfileDTO(name: "test", image: "av-dark-green", active: false, user: user._id ?? "")
        let request = ProfileHTTPDTO.POST.Request(user: user, profile: profile)
        
        let response = await userUseCase.request(endpoint: .createUserProfile, for: ProfileHTTPDTO.POST.Response.self, request: request)
        
        guard let response = response else { return }
        
        self.selectedProfile = response.data.toDomain()
    }
    
    func updateUserProfileForSigningOut() async -> Bool {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return false }
        
        let request = UserHTTPDTO.Request(user: user, selectedProfile: nil)
        
        let response = await userUseCase.request(endpoint: .updateUserData, for: UserHTTPDTO.Response.self, request: request)
        
        guard let _ = response else { return false }
        
        return true
    }
    
    func userProfileDidUpdate(with profileId: String) async {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let request = UserHTTPDTO.Request(user: user, selectedProfile: profileId)
        
        let response = await userUseCase.request(endpoint: .updateUserData, for: UserHTTPDTO.Response.self, request: request)
        
        guard let _ = response else { return }
        
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

// MARK: - Private Implementation

extension ProfileViewModel {
    private func createUseCase() -> UserUseCase {
        let services = Application.app.services
        let authService = services.auth
        let dataTransferService = services.dataTransfer
        let persistentStore = UserHTTPResponseStore(authService: authService)
        let authenticator = UserRepositoryAuthenticator(dataTransferService: dataTransferService, persistentStore: persistentStore)
        let invoker = RepositoryInvoker(dataTransferService: dataTransferService, persistentStore: persistentStore)
        let repository = UserRepository(dataTransferService: dataTransferService, authenticator: authenticator, persistentStore: persistentStore, invoker: invoker)
        return UserUseCase(repository: repository)
    }
}
