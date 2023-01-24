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
        let authService = Application.current.authService
        let coordinator = Application.current.rootCoordinator
        // Ensure the properties aren't nil.
        guard let email = email,
              let password = password else {
            return
        }
        // Create a new user.
        let userDTO = UserDTO(email: email, password: password)
        // Create a new sign in request user-based.
        let requestDTO = AuthRequestDTO(user: userDTO)
        // Invoke the request.
        viewModel.signIn(
            request: requestDTO.toDomain(),
            cached: { _ in },
            completion: { result in
                switch result {
                case .success(let response):
                    // Set authentication response.
                    authService.setResponse(request: response.request, response: response)
                    // Present the TabBar screen.
                    asynchrony {
                        coordinator.showScreen(.tabBar)
                    }
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            })
    }
}
