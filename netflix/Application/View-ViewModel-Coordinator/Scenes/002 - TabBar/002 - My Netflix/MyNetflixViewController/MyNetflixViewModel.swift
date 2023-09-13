//
//  MyNetflixViewModel.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import Foundation

// MARK: - MyNetflixViewModel Type

final class MyNetflixViewModel {
    var coordinator: MyNetflixCoordinator?
    
    var selectedProfile: Profile?
    
    private(set) lazy var userUseCase: UserUseCase = createUserUseCase()
    
    private(set) lazy var menuItems: [MyNetflixMenuItem] = createMenuItems()
}

// MARK: - ViewModel Implementation

extension MyNetflixViewModel: ViewModel {}

// MARK: - Private Implementation

extension MyNetflixViewModel {
    private func createUserUseCase() -> UserUseCase {
        let services = Application.app.services
        let stores = Application.app.stores
        let dataTransferService = services.dataTransfer
        let userResponseStorage = stores.userResponses
        let userRepository = UserRepository(dataTransferService: dataTransferService, persistentStore: userResponseStorage)
        return UserUseCase(repository: userRepository)
    }
    
    private func createMenuItems() -> [MyNetflixMenuItem] {
        let list = Application.app.services.myList
        let media = list.list.toArray()
        
        let myNetflix = MyNetflixMenuItem(title: "My Netflix",
                                          hasImage: false,
                                          hasAccessory: true)
        let notifications = MyNetflixMenuItem(image: "bell.fill",
                                              title: "Notifications",
                                              isExpanded: true,
                                              items: media,
                                              color: Color(color: .red),
                                              hasImage: true,
                                              hasAccessory: true)
        let downloads = MyNetflixMenuItem(image: "arrow.down.to.line",
                                          title: "Downloads",
                                          color: Color(color: .link),
                                          hasImage: true,
                                          hasAccessory: true)
        let myList = MyNetflixMenuItem(image: "checkmark",
                                       title: "My List",
                                       isExpanded: false,
                                       items: media,
                                       hasImage: false,
                                       hasAccessory: true)
        let trailersWatched = MyNetflixMenuItem(title: "Trailers You've Watched",
                                                hasImage: false,
                                                hasAccessory: false)
        
        let items = [myNetflix, notifications, downloads, myList, trailersWatched]
        return items
    }
    
    func getSelectedProfile(_ completion: ((ProfileHTTPDTO.GET.Response?) -> Void)?) {
        let authService = Application.app.services.auth
        
        guard let user = authService.user,
              let selectedProfileId = user.selectedProfile
        else { return }
        
        let request = ProfileHTTPDTO.GET.Request(user: user, _id: selectedProfileId)
        
        userUseCase.repository.task = userUseCase.request(endpoint: .getUserProfiles,
                                                          for: ProfileHTTPDTO.GET.Response.self,
                                                          request: request,
                                                          cached: { _ in },
                                                          completion: { result in
            switch result {
            case .success(let response):
                completion?(response)
            case .failure(let error):
                completion?(nil)
                printIfDebug(.debug, "\(error)")
            }
        })
    }
}
