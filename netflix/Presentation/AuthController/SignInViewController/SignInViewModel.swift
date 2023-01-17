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
        // User's data transfer object.
        let userDTO = UserDTO(email: email, password: password)
        
        // Authenticate the user.
        authService.authenticate(user: userDTO)
        
        // Present the tab bar screen.
        asynchrony {
            coordinator.showScreen(.tabBar)
        }
    }
}
