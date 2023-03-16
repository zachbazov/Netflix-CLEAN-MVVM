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
    
    func userProfilesDidLoad() async
    
    func didFinish()
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - ProfileViewModel Type

final class ProfileViewModel {
    var coordinator: ProfileCoordinator?
    
    fileprivate lazy var userUseCase = UserUseCase()
    
    var profiles = [UserProfile]()
    var selectedProfile: UserProfile?
}

// MARK: - ViewModel Implementation

extension ProfileViewModel: ViewModel {
    func viewDidLoad() {
        loadData()
        
//        Task {
//            print("creating")
//            await createUserProfile()
//        }
    }
}

// MARK: - ViewModelProtocol Implementation

extension ProfileViewModel: ViewModelProtocol {
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
                    self.profiles = response.data.toDomain()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    fileprivate func userProfilesDidLoad() async {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.GET.Request(user: user)
        let response = await userUseCase.request(for: UserProfileHTTPDTO.GET.Response.self, request: request)
        
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
    
    fileprivate func createUserProfile() async -> UserProfileHTTPDTO.POST.Response? {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return nil }
        
        let profile = UserProfileDTO(name: "test", image: "av-dark-green", active: false, user: user._id ?? "")
        let request = UserProfileHTTPDTO.POST.Request(user: user, profile: profile)
        
        let response = await userUseCase.request(for: UserProfileHTTPDTO.POST.Response.self, request: request)
        
        guard let response = response else { return nil }
        
        self.selectedProfile = response.data.toDomain()
        
        return response
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
