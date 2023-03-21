//
//  SignInViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func didFinish(with user: UserDTO?)
}

private protocol ViewModelOutput {
    var email: String? { get }
    var password: String? { get }
    
    func signInButtonDidTap()
    func signInRequest()
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

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

// MARK: - Coordinable Implementation

extension SignInViewModel: Coordinable {}

// MARK: - ViewModelProtocol Implementation

extension SignInViewModel: ViewModelProtocol {
    /// Occurs once the sign in button has been tapped.
    @objc
    func signInButtonDidTap() {
        signInRequest()
    }
    
    /// Invokes a sign in request for the user credentials.
    fileprivate func signInRequest() {
        let authService = Application.app.services.authentication
        
        guard let emailTextField = coordinator?.signInController.emailTextField,
              let passTextField = coordinator?.signInController.passwordTextField else { return }
        
        emailTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        
        guard let email = email, let password = password else { return }
        
        guard email.isNotEmpty, password.isNotEmpty else { return }
        
        ActivityIndicatorView.viewDidShow()
        
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = UserHTTPDTO.Request(user: userDTO, selectedProfile: nil)
        
        if #available(iOS 13.0, *) {
            Task {
                let response = await authService.signIn(with: requestDTO)
                
                guard let user = response?.data else { return }
                
                didFinish(with: user)
            }
            
            return
        }
        
        authService.signIn(for: requestDTO) { [weak self] user in
            self?.didFinish(with: user)
        }
    }
    
    fileprivate func didFinish(with user: UserDTO?) {
        ActivityIndicatorView.viewDidHide()
        
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            let emailTextField = self.coordinator?.signInController.emailTextField
            let passTextField = self.coordinator?.signInController.passwordTextField
            
            guard user.isNotNil else {
                emailTextField?.text?.toBlankValue()
                passTextField?.text?.toBlankValue()
                return
            }
            
            guard let selectedProfile = user?.selectedProfile, selectedProfile.isNotEmpty else {
                let coordinator = Application.app.coordinator
                coordinator.coordinate(to: .profile)
                return
            }
            
            let coordinator = Application.app.coordinator
            coordinator.coordinate(to: .tabBar)
        }
    }
}
