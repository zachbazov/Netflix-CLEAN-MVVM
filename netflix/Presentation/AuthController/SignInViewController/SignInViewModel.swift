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
    @objc
    func signInButtonDidTap() {
        let authService = Application.current.authService
        let coordinator = Application.current.rootCoordinator
        /// User's data transfer object.
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = AuthRequestDTO(user: userDTO)
        /// Invoke a sign-up request.
        viewModel.signIn(request: requestDTO.toDomain()) { [weak self] result in
            if case let .success(responseDTO) = result {
                let userDTO = responseDTO.data
                userDTO?.token = responseDTO.token
                /// Authenticate the user.
                authService.authenticate(user: userDTO)
                UserGlobal.user = userDTO!
                UserGlobal.password = self!.password!
                
                /// Present the tab bar screen.
                asynchrony {
                    coordinator.showScreen(.tabBar)
                }
            }
            if case let .failure(error) = result { print(error) }
        }
    }
}
