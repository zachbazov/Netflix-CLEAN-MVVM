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
    func updateUserProfile(with request: ProfileHTTPDTO.PATCH.Request, _ completion: @escaping () -> Void)
    func updateUserProfileSettings(with request: ProfileHTTPDTO.Settings.PATCH.Request, _ completion: @escaping () -> Void)
    func updateUserSelectedProfile(with profileId: String, _ completion: @escaping () -> Void)
    func updateUserProfileForSigningOut(completion: @escaping () -> Void)
    
    func didFinish()
}

// MARK: - ProfileViewModel Type

final class ProfileViewModel {
    var coordinator: ProfileCoordinator?
    
    fileprivate(set) lazy var userUseCase: UserUseCase = createUseCase()
    
    var profiles = [Profile]()
    
    var selectedProfile: Profile?
    
    /**
     The `editingProfile` property represents the user profile currently being edited.
     
     - Note:
     Use this property to track and manage the user profile that is currently in the editing mode. It holds an optional `Profile` object, allowing you to reference the user's profile when in edit mode and set it to `nil` when there is no active editing session.
     
     - Important:
     - When `editingProfile` is `nil`, there is no active editing session.
     - Use this property in conjunction with your UI to display and manipulate the user's profile during editing.
     
     */
    var editingProfile: Profile?
    
    var currentProfile: Profile? {
        guard let profileIndex = profileIndex else { return nil }
        return profiles[profileIndex]
    }
    
    var profileIndex: Int?
    
    var profileName: String?
    
    var isEditing: Bool = false
    
    var hasChanges: Bool {
        return currentProfile == editingProfile
    }
    
    var isDeleting: Bool = false
    
    lazy var profileSettings: [ProfileSetting] = createProfileSettings()
    
    func add(_ profile: Profile) {
        let priorToLast = profiles.count - 1
        profiles.insert(profile, at: priorToLast)
    }
    
    func setEditingProfile(_ profile: Profile) {
        editingProfile = profile
    }
    
    func updateProfile(_ profileDTO: ProfileDTO, at index: Int) {
        profiles[index] = profileDTO.toDomain()
    }
    
    func createProfileSettings() -> [ProfileSetting] {
        let maturityRatingSetting = ProfileSetting(image: "exclamationmark.octagon",
                                                   title: "Maturiy Rating",
                                                   subtitle: "No restrictions",
                                                   hasSubtitle: true,
                                                   isSwitchable: false)
        let displayLanguageSetting = ProfileSetting(image: "textformat",
                                                    title: "Display Language",
                                                    subtitle: "English",
                                                    hasSubtitle: true,
                                                    isSwitchable: false)
        let audioAndSubtitlesSetting = ProfileSetting(image: "text.bubble.fill",
                                                      title: "Audio & Subtitles",
                                                      subtitle: "English",
                                                      hasSubtitle: true,
                                                      isSwitchable: false)
        let autoplayNextEpisodeSetting = ProfileSetting(image: "arrow.right.square",
                                                        title: "Autoplay Next Episode",
                                                        hasSubtitle: false,
                                                        isSwitchable: true)
        let autoplayPreviewsSetting = ProfileSetting(image: "autostartstop",
                                                     title: "Autoplay Previews",
                                                     hasSubtitle: false,
                                                     isSwitchable: true)
        
        return [maturityRatingSetting,
                displayLanguageSetting,
                audioAndSubtitlesSetting,
                autoplayNextEpisodeSetting,
                autoplayPreviewsSetting]
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
                    self.add(response.data.toDomain())
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
    
    func updateUserProfile(with request: ProfileHTTPDTO.PATCH.Request, _ completion: @escaping () -> Void) {
        userUseCase.repository.task = userUseCase.request(
            endpoint: .updateUserProfile,
            for: ProfileHTTPDTO.PATCH.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    guard let profileIndex = self.profileIndex else { return }
                    
                    self.updateProfile(response.data, at: profileIndex)
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.debug, "\(error)")
                }
            })
    }
    
    func updateUserProfileSettings(with request: ProfileHTTPDTO.Settings.PATCH.Request, _ completion: @escaping () -> Void) {
        userUseCase.repository.task = userUseCase.request(
            endpoint: .updateUserProfileSettings,
            for: ProfileHTTPDTO.Settings.PATCH.Response.self,
            request: request,
            cached: { _ in },
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    guard let profileIndex = self.profileIndex else { return }
                    
                    self.profiles[profileIndex].settings = response.data.toDomain()
                    
                    completion()
                case .failure(let error):
                    printIfDebug(.debug, "\(error)")
                }
            })
    }
    
    func updateUserSelectedProfile(with profileId: String, _ completion: @escaping () -> Void) {
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
    
    func deleteUserProfile(_ profileId: String, _ completion: @escaping () -> Void) {
        let authService = Application.app.services.auth
        
        guard let user = authService.user else { return }
        
        let request = ProfileHTTPDTO.DELETE.Request(user: user, id: profileId)
        
        userUseCase.repository.task = userUseCase.request(
            endpoint: .deleteUserProfile,
            request: request,
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.profiles.removeAll(where: { $0._id == profileId })
                    
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
