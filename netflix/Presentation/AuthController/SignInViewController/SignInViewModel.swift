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
        
        
        // User's data transfer object.
        let userDTO = UserDTO(email: email, password: password)
        // Authenticate the user.
//        authService.authenticate(user: userDTO)
        // Present the tab bar screen.
//        asynchrony {
//            coordinator.showScreen(.tabBar)
//        }
        
        printIfDebug(.debug, "signInButtonDidTap \(userDTO.toDomain())")
        
        
        let requestDTO = AuthRequestDTO(user: userDTO)
        let authViewModel = AuthViewModel()
        authViewModel.signIn(
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
