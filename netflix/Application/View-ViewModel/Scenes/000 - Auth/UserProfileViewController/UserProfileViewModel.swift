//
//  UserProfileViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    
}

private protocol ViewModelOutput {
    
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - UserProfileViewModel Type

final class UserProfileViewModel {
    var coordinator: UserProfileCoordinator?
    
    fileprivate lazy var userUseCase = UserUseCase()
    
    var profiles = [UserProfile]()
    
    func viewDidLoad() {
        loadData()
    }
}

// MARK: - ViewModel Implementation

extension UserProfileViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension UserProfileViewModel: ViewModelProtocol {}

// MARK: - Private UI Implementation

extension UserProfileViewModel {
    private func loadData() {
        if #available(iOS 13.0, *) {
            return awaitLoading()
        }
        
        getMyUserProfiles()
    }
    
    private func awaitLoading() {
        let vc = coordinator?.viewController
        
        Task {
            await myUserProfilesDidLoad()
            
            await vc?.dataSourceDidChange()
        }
    }
    
    private func getMyUserProfiles() {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.Request(user: user)
        
        userUseCase.repository.task = userUseCase.request(
            for: UserProfileHTTPDTO.Response.self,
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
    
    private func myUserProfilesDidLoad() async {
        let authService = Application.app.services.authentication
        
        guard let user = authService.user else { return }
        
        let request = UserProfileHTTPDTO.Request(user: user)
        let response = await userUseCase.request(for: UserProfileHTTPDTO.Response.self, request: request)
        
        guard let profiles = response?.data.toDomain() else { return }
        
        self.profiles = profiles
        
        let addProfile = UserProfile(_id: "", name: "Add Profile", image: "plus", active: false, user: user._id!)
        
        self.profiles.append(addProfile)
    }
}
