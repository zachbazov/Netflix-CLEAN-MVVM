//
//  SignUpViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var name: String? { get }
    var email: String? { get }
    var password: String? { get }
    var passwordConfirm: String? { get }
    
    func signUpButtonDidTap()
    func signUpRequest()
}

private typealias ViewModelProtocol = ViewModelOutput

// MARK: - SignUpViewModel Type

final class SignUpViewModel {
    var coordinator: AuthCoordinator?
    private let viewModel: AuthViewModel
    
    var name: String?
    var email: String?
    var password: String?
    var passwordConfirm: String?
    
    init(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - ViewModel Implementation

extension SignUpViewModel: ViewModel {}

// MARK: - Coordinable Implementation

extension SignUpViewModel: Coordinable {}

// MARK: - ViewModelProtocol Implementation

extension SignUpViewModel: ViewModelProtocol {
    /// Occurs once the sign up button has been tapped.
    @objc
    func signUpButtonDidTap() {
        signUpRequest()
    }
    /// Invokes a sign up request by the user credentials.
    fileprivate func signUpRequest() {
        let authService = Application.app.services.authentication
        let coordinator = Application.app.coordinator
        
        let nameTextField = coordinator.authCoordinator.signUpController.nameTextField
        let emailTextField = coordinator.authCoordinator.signUpController.emailTextField
        let passTextField = coordinator.authCoordinator.signUpController.passwordTextField
        let passConfirmTextField = coordinator.authCoordinator.signUpController.passwordConfirmTextField
        nameTextField?.resignFirstResponder()
        emailTextField?.resignFirstResponder()
        passTextField?.resignFirstResponder()
        passConfirmTextField?.resignFirstResponder()
        
        guard !(nameTextField?.text?.isEmpty ?? false),
              !(emailTextField?.text?.isEmpty ?? false),
              !(passTextField?.text?.isEmpty ?? false),
              !(passConfirmTextField?.text?.isEmpty ?? false) else {
            return
        }
        
        ActivityIndicatorView.viewDidShow()
        
        let userDTO = UserDTO(name: name,
                              email: email,
                              password: password,
                              passwordConfirm: passwordConfirm)
        
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        
        if #available(iOS 13.0, *) {
            Task {
                let status = await authService.signUp(with: requestDTO)
                
                mainQueueDispatch { [weak self] in
                    self?.didFinish(with: status)
                }
            }
            
            return
        }
        
        authService.signUp(for: requestDTO) { status in
            mainQueueDispatch { [weak self] in
                self?.didFinish(with: status)
            }
        }
    }
    
    private func didFinish(with status: Bool) {
        let nameTextField = coordinator?.signUpController.nameTextField
        let emailTextField = coordinator?.signUpController.emailTextField
        let passTextField = coordinator?.signUpController.passwordTextField
        let passConfirmTextField = coordinator?.signUpController.passwordConfirmTextField
        
        guard status else {
            nameTextField?.text = ""
            emailTextField?.text = ""
            passTextField?.text = ""
            passConfirmTextField?.text = ""
            return
        }
        
        ActivityIndicatorView.viewDidHide()
        
        let coordinator = Application.app.coordinator
        coordinator.coordinate(to: .tabBar)
    }
}
