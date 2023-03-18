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
        
        guard let nameTextField = coordinator.authCoordinator.signUpController.nameTextField,
              let emailTextField = coordinator.authCoordinator.signUpController.emailTextField,
              let passTextField = coordinator.authCoordinator.signUpController.passwordTextField,
              let passConfirmTextField = coordinator.authCoordinator.signUpController.passwordConfirmTextField else { return }
        
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        passConfirmTextField.resignFirstResponder()
        
        guard let name = name,
              let email = email,
              let password = password,
              let passwordConfirm = passwordConfirm else { return }
        
        guard name.isNotEmpty,
              email.isNotEmpty,
              password.isNotEmpty,
              passwordConfirm.isNotEmpty else { return }
        
        ActivityIndicatorView.viewDidShow()
        
        let userDTO = UserDTO(name: name,
                              email: email,
                              password: password,
                              passwordConfirm: passwordConfirm)
        
        let requestDTO = UserHTTPDTO.POST.Request(user: userDTO)
        
        if #available(iOS 13.0, *) {
            Task {
                let status = await authService.signUp(with: requestDTO)
                
                didFinish(with: status)
            }
            
            return
        }
        
        authService.signUp(for: requestDTO) { [weak self] status in
            self?.didFinish(with: status)
        }
    }
    
    private func didFinish(with status: Bool) {
        ActivityIndicatorView.viewDidHide()
        
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            let nameTextField = self.coordinator?.signUpController.nameTextField
            let emailTextField = self.coordinator?.signUpController.emailTextField
            let passTextField = self.coordinator?.signUpController.passwordTextField
            let passConfirmTextField = self.coordinator?.signUpController.passwordConfirmTextField
            
            guard status else {
                nameTextField?.text?.toBlankValue()
                emailTextField?.text?.toBlankValue()
                passTextField?.text?.toBlankValue()
                passConfirmTextField?.text?.toBlankValue()
                return
            }
            
            let coordinator = Application.app.coordinator
            coordinator.coordinate(to: .profile)
        }
    }
}
