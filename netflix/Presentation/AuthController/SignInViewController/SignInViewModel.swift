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
            cached: { responseDTO in
                printIfDebug(.debug, "cachedddd")
                guard let responseDTO = responseDTO else { return }
                authService.authenticate(for: responseDTO)
                asynchrony {
                    coordinator.showScreen(.tabBar)
                }
            },
            completion: { result in
                if case let .success(responseDTO) = result {
                    printIfDebug(.debug, "comppppleee")
                    authService.authenticate(for: responseDTO)
                    asynchrony {
                        coordinator.showScreen(.tabBar)
                    }
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "Unresolved error \(error)")
                }
            })
    }
}
