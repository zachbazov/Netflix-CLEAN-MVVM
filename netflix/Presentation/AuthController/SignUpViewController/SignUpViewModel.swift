//
//  SignUpViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - SignUpViewModel Type

final class SignUpViewModel {
    
    // MARK: Properties
    
    private let viewModel: AuthViewModel
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirm: String?
    
    // MARK: Initializer
    
    init(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Methods

extension SignUpViewModel {
    /// Occurs once the sign up button has been tapped.
    @objc
    func signUpButtonDidTap() {
        signUpRequest()
    }
    /// Invokes a sign up request by the user credentials.
    private func signUpRequest() {
        let authService = Application.app.services.authentication
        let coordinator = Application.app.sceneCoordinator
        // Create a new user.
        let userDTO = UserDTO(name: name,
                              email: email,
                              password: password,
                              passwordConfirm: passwordConfirm)
        // Create a new sign up request user-based.
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        // Invoke the request.
        authService.signUpRequest(requestDTO: requestDTO) {
            // Present the TabBar screen.
            mainQueueDispatch {
                coordinator.deploy(screen: .tabBar)
            }
        }
    }
}
