//
//  SignInViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 07/12/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    func signInButtonDidTap()
    func signInRequest()
}

private protocol ViewModelOutput {
    var email: String? { get }
    var password: String? { get }
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - SignInViewModel Type

final class SignInViewModel: ViewModel {
    var coordinator: AuthCoordinator?
    private let viewModel: AuthViewModel
    
    var email: String?
    var password: String?
    
    init(with viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    func transform(input: Void) {}
}

extension SignInViewModel: Coordinable {}

// MARK: - ViewModelProtocol Implementation

extension SignInViewModel: ViewModelProtocol {
    /// Occurs once the sign in button has been tapped.
    @objc
    func signInButtonDidTap() {
        ActivityIndicatorView.viewDidShow()
        
        signInRequest()
    }
    /// Invokes a sign in request for the user credentials.
    fileprivate func signInRequest() {
        let authService = Application.app.services.authentication
        let coordinator = Application.app.coordinator
        // Ensure the properties aren't nil.
        guard let email = email, let password = password else { return }
        // Create a new user.
        let userDTO = UserDTO(email: email, password: password)
        // Create a new sign in request user-based.
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        // Invoke the request.
        authService.signIn(for: requestDTO) {
            // Hide indicator.
            ActivityIndicatorView.viewDidHide()
            // Present the TabBar screen.
            mainQueueDispatch {
                coordinator.coordinate(to: .tabBar)
            }
        }
    }
}
