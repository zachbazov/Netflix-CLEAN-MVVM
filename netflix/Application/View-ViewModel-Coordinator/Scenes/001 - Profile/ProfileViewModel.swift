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
    
    func getUserProfiles(_ completion: @escaping () -> Void)
    func createUserProfile(with request: ProfileHTTPDTO.POST.Request, _ completion: @escaping () -> Void)
    func updateUserProfile(with profileId: String, _ completion: @escaping () -> Void)
    func updateUserProfileForSigningOut(completion: @escaping () -> Void)
    
    func didFinish()
}

// MARK: - ProfileViewModel Type

final class ProfileViewModel {
    var coordinator: ProfileCoordinator?
    
    fileprivate(set) lazy var userUseCase: UserUseCase = createUseCase()
    
    var profiles = [Profile]()
    var selectedProfile: Profile?
    var editingProfile: Profile?
    
    var profileName: String?
    
    var isEditing: Bool = false
    
    func add(_ profile: Profile) {
        let priorToLast = profiles.count - 1
        profiles.insert(profile, at: priorToLast)
    }
}

// MARK: - ViewModel Implementation

extension ProfileViewModel: ViewModel {
    func viewDidLoad() {
        getUserProfiles() { [weak self] in
            guard let self = self else { return }
            
            self.didFinish()
        }
    }
}

// MARK: - ViewModelProtocol Implementation

extension ProfileViewModel: ViewModelProtocol {
    fileprivate func getUserProfiles(_ completion: @escaping () -> Void) {
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
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func createUserProfile(with request: ProfileHTTPDTO.POST.Request, _ completion: @escaping () -> Void) {
        userUseCase.repository.task = userUseCase.request(
            endpoint: .createUserProfile,
            for: ProfileHTTPDTO.POST.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.selectedProfile = response.data.toDomain()
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func updateUserProfile(with profileId: String, _ completion: @escaping () -> Void) {
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
                    completion()
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
    
    fileprivate func didFinish() {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            guard let controller = self.coordinator?.userProfileController,
                  let dataSource = controller.dataSource
            else { return }
            
            self.profiles.append(Profile.addProfile)
            
            controller.collectionView?.setCollectionViewLayout(controller.createLayout(), animated: false)
            dataSource.dataSourceDidChange()
        }
    }
}

// MARK: - Private Implementation

extension ProfileViewModel {
    private func createUseCase() -> UserUseCase {
        let services = Application.app.services
        let stores = Application.app.stores
        let dataTransferService = services.dataTransfer
        let persistentStore = stores.userResponses
        let repository = UserRepository(dataTransferService: dataTransferService, persistentStore: persistentStore)
        return UserUseCase(repository: repository)
    }
}
