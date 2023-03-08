//
//  SignInViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func didFinish(with status: Bool)
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
        let coordinator = Application.app.coordinator
        
        let emailTextField = coordinator.authCoordinator.signInController.emailTextField
        let passTextField = coordinator.authCoordinator.signInController.passwordTextField
        emailTextField?.resignFirstResponder()
        passTextField?.resignFirstResponder()
        
        guard !(emailTextField?.text?.isEmpty ?? false),
              !(passTextField?.text?.isEmpty ?? false) else {
            return
        }
        
        guard let email = email, let password = password else { return }
        
        ActivityIndicatorView.viewDidShow()
        
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        
        if #available(iOS 13.0, *) {
            Task {
                let status = await authService.signIn(with: requestDTO)
                
                didFinish(with: status)
            }
            
            return
        }
        
        authService.signIn(for: requestDTO) { [weak self] status in
            self?.didFinish(with: status)
        }
    }
    
    fileprivate func didFinish(with status: Bool) {
        let coordinator = Application.app.coordinator
        
        let emailTextField = coordinator.authCoordinator.signInController.emailTextField
        let passTextField = coordinator.authCoordinator.signInController.passwordTextField
        
        guard status else {
            emailTextField?.text = ""
            passTextField?.text = ""
            return
        }
        
        mainQueueDispatch {
            coordinator.coordinate(to: .tabBar)
        }
    }
}
