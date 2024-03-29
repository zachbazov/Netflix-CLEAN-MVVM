//
//  SignInViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var email: String? { get }
    var password: String? { get }
    
    func signInButtonDidTap()
    func signInRequest()
    func didFinish(with user: UserDTO?)
}

// MARK: - SignInViewModel Type

final class SignInViewModel {
    var coordinator: AuthCoordinator?
    private let viewModel: AuthViewModel
    
    var email: String?
    var password: String?
    
    init(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - ViewModel Implementation

extension SignInViewModel: ViewModel {}

// MARK: - CoordinatorAssignable Implementation

extension SignInViewModel: CoordinatorAssignable {}

// MARK: - ViewModelProtocol Implementation

extension SignInViewModel: ViewModelProtocol {
    /// Occurs once the sign in button has been tapped.
    @objc
    func signInButtonDidTap() {
        signInRequest()
    }
    
    /// Invokes a sign in request for the user credentials.
    fileprivate func signInRequest() {
        let authService = Application.app.services.auth

        guard let emailTextField = coordinator?.signInController?.emailTextField,
              let passTextField = coordinator?.signInController?.passwordTextField
        else { return }

        emailTextField.resignFirstResponder()
        passTextField.resignFirstResponder()

        guard let email = email, let password = password else { return }

        guard email.isNotEmpty, password.isNotEmpty else { return }

        ActivityIndicatorView.present()

        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = UserHTTPDTO.Request(user: userDTO, selectedProfile: nil)
        
        authService.signIn(for: requestDTO) { [weak self] user in
            self?.didFinish(with: user)
        }
    }
    
    fileprivate func didFinish(with user: UserDTO?) {
        ActivityIndicatorView.remove()
        
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            let emailTextField = self.coordinator?.signInController?.emailTextField
            let passTextField = self.coordinator?.signInController?.passwordTextField

            guard let user = user else {
                emailTextField?.text = .toBlank()
                passTextField?.text = .toBlank()
                return
            }

            guard let selectedProfile = user.selectedProfile, selectedProfile.isNotEmpty else {
                let coordinator = Application.app.coordinator
                coordinator.coordinate(to: .profile)
                return
            }

            let coordinator = Application.app.coordinator
            coordinator.coordinate(to: .tabBar)
        }
    }
}
