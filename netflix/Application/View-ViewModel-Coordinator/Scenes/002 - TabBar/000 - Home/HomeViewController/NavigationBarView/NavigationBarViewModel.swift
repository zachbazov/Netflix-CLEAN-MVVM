//
//  NavigationBarViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 18/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {}

// MARK: - NavigationBarViewModel Type

final class NavigationBarViewModel {
    let coordinator: HomeViewCoordinator
    
    /// Create a navigation view view model object.
    /// - Parameters:
    ///   - items: Represented items on the navigation.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.coordinator = viewModel.coordinator!
    }
}

// MARK: - ViewModel Implementation

extension NavigationBarViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension NavigationBarViewModel: ViewModelProtocol {
    func getUserProfiles(_ completion: @escaping (Profile?) -> Void) {
        let authService = Application.app.services.auth
        let profileViewModel = ProfileViewModel()
        
        guard let user = authService.user else { return }
        
        let request = ProfileHTTPDTO.GET.Request(user: user)
        
        _ = profileViewModel.userUseCase.request(
            endpoint: .getUserProfiles,
            for: ProfileHTTPDTO.GET.Response.self,
            request: request,
            cached: { _ in },
            completion: { result in
                switch result {
                case .success(let response):
                    guard let profile = response.data.toDomain().first(where: { user.selectedProfile == $0._id }) else { return }
                    
                    completion(profile)
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                    
                    completion(nil)
                }
            })
    }
    
    /// Controls the navigation presentation of items.
    /// - Parameter state: Corresponding state.
    func stateDidChange(_ state: NavigationBarView.State) {
        switch state {
        case .airPlay:
            guard let controller = coordinator.viewController,
                  let navigation = controller.navigationView?.navigationBar
            else { return }
            navigation.airPlayButton.asRoutePickerView()
        case .search:
            coordinator.coordinate(to: .search)
        case .account:
            coordinator.coordinate(to: .account)
        }
    }
}
