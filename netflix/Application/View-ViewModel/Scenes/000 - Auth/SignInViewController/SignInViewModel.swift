//
//  SignInViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelOutput {
    var email: String? { get }
    var password: String? { get }
    
    func signInButtonDidTap()
    func signInRequest()
}

private typealias ViewModelProtocol = ViewModelOutput

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
            AlertView.shared.present(state: .failure, title: "AUTHORIZATION", message: "Incorrect credentials.")
            return
        }
        // Ensure the properties aren't nil.
        guard let email = email, let password = password else { return }
        // Present indicator.
        ActivityIndicatorView.viewDidShow()
        // Create a new user.
        let userDTO = UserDTO(email: email, password: password)
        // Create a new sign in request user-based.
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        // Invoke the request.
        authService.signIn(for: requestDTO) { success in
            // Hide indicator.
            ActivityIndicatorView.viewDidHide()
            // In case of success response.
            guard success else {
                // Else, reset fields text.
                emailTextField?.text = ""
                passTextField?.text = ""
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
