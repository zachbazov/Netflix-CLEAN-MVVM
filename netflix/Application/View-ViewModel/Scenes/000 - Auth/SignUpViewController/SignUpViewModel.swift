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
        emailTextField?.resignFirstResponder()
        passTextField?.resignFirstResponder()
        
        guard !(nameTextField?.text?.isEmpty ?? false),
              !(emailTextField?.text?.isEmpty ?? false),
              !(passTextField?.text?.isEmpty ?? false),
              !(passConfirmTextField?.text?.isEmpty ?? false) else {
            AlertView.shared.present(state: .failure, title: "AUTHORIZATION", message: "Incorrect credentials.")
            return
        }
        // Present indicator.
        ActivityIndicatorView.viewDidShow()
        // Create a new user.
        let userDTO = UserDTO(name: name,
                              email: email,
                              password: password,
                              passwordConfirm: passwordConfirm)
        // Create a new sign up request user-based.
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        // Invoke the request.
        authService.signUp(for: requestDTO) { success in
            // Hide indicator.
            ActivityIndicatorView.viewDidHide()
            // In case of success response.
            guard success else {
                // Else, reset fields text.
                nameTextField?.text = ""
                emailTextField?.text = ""
                passTextField?.text = ""
                passConfirmTextField?.text = ""
                return
            }
            AlertView.shared.present(state: .success, title: "AUTHORIZATION", message: "Access Granted.")
            // Present the TabBar screen.
            mainQueueDispatch(delayInSeconds: 4) {
                AlertView.shared.removeFromSuperview()
                coordinator.coordinate(to: .tabBar)
            }
        }
    }
}
