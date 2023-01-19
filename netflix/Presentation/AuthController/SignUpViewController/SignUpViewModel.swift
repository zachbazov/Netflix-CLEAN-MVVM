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
    @objc
    func signUpButtonDidTap() {
        let authService = Application.current.authService
        let coordinator = Application.current.rootCoordinator
        /// User's data transfer object.
        let userDTO = UserDTO(name: name,
                              email: email,
                              password: password,
                              passwordConfirm: passwordConfirm)
        let requestDTO = AuthRequestDTO(user: userDTO)
        /// Invoke a sign-up request.
        viewModel.signUp(request: requestDTO.toDomain()) { result in
            if case let .success(responseDTO) = result {
                let user = userDTO
                user._id = responseDTO.data?._id
                user.token = responseDTO.token
                authService.authenticate(user: user)
                authService.cachedAuthorizationRequest {
                    asynchrony { coordinator.showScreen(.tabBar) }
                }
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        }
    }
}
