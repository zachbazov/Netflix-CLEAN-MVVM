//
//  SignUpViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func signUpButtonDidTap()
    func signUpRequest()
}

private protocol ViewModelOutput {
    var name: String? { get }
    var email: String? { get }
    var password: String? { get }
    var passwordConfirm: String? { get }
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - SignUpViewModel Type

final class SignUpViewModel: ControllerViewModel {
    var coordinator: AuthCoordinator?
    private let viewModel: AuthViewModel
    
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirm: String?
    
    init(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    func transform(input: Void) {}
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
        let coordinator = Application.app.coordinator
        // Create a new user.
        let userDTO = UserDTO(name: name,
                              email: email,
                              password: password,
                              passwordConfirm: passwordConfirm)
        // Create a new sign up request user-based.
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        // Invoke the request.
        authService.signUp(for: requestDTO) {
            mainQueueDispatch {
                // Present the TabBar screen.
                coordinator.coordinate(to: .tabBar)
            }
        }
    }
}
