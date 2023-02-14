//
//  SignInViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - SignInViewModel Type

final class SignInViewModel {
    
    // MARK: Properties
    
    private let viewModel: AuthViewModel
    var email: String?
    var password: String?
    
    // MARK: Initializer
    
    init(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Methods

extension SignInViewModel {
    /// Occurs once the sign in button has been tapped.
    @objc
    func signInButtonDidTap() {
        signInRequest()
    }
    /// Invokes a sign in request for the user credentials.
    private func signInRequest() {
        let authService = Application.app.services.authentication
        let coordinator = Application.app.sceneCoordinator
        // Ensure the properties aren't nil.
        guard let email = email,
              let password = password else {
            return
        }
        // Create a new user.
        let userDTO = UserDTO(email: email, password: password)
        // Create a new sign in request user-based.
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        // Invoke the request.
        authService.signInRequest(requestDTO: requestDTO) {
            // Present the TabBar screen.
            mainQueueDispatch {
                coordinator.deploy(screen: .tabBar)
            }
        }
    }
}
