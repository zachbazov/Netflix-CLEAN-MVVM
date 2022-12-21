//
//  AuthCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

private protocol AuthCoordinable {
    func allocateLandpageDependencies() -> LandpageViewController
    func allocateSignInDependencies() -> SignInViewController
    func allocateSignUpDependencies() -> SignUpViewController
    func present(_ sender: Any)
}

final class AuthCoordinator {
    var viewController: AuthController?
    private lazy var landpageController: LandpageViewController = allocateLandpageDependencies()
    private lazy var signInController: SignInViewController = allocateSignInDependencies()
    private lazy var signUpController: SignUpViewController = allocateSignUpDependencies()
}

extension AuthCoordinator: AuthCoordinable {
    fileprivate func allocateLandpageDependencies() -> LandpageViewController {
        let controller = LandpageViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    fileprivate func allocateSignInDependencies() -> SignInViewController {
        let controller = SignInViewController()
        let viewModel = SignInViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        return controller
    }
    
    fileprivate func allocateSignUpDependencies() -> SignUpViewController {
        let controller = SignUpViewController()
        let viewModel = SignUpViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        return controller
    }
    /// Push a new controller to the navigation stack.
    /// - Parameter sender: The object that's been interacted with.
    @objc
    func present(_ sender: Any) {
        if let sender = sender as? LandpageViewController {
            viewController?.pushViewController(sender, animated: true)
        } else if let sender = sender as? UIBarButtonItem,
           sender.title == "Sign In" {
            viewController?.pushViewController(signInController, animated: true)
        } else if let sender = sender as? UIButton,
           sender.titleLabel!.text == "Sign Up" {
            viewController?.pushViewController(signUpController, animated: true)
        }
    }
}

extension AuthCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case landpage
        case signIn
        case signUp
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func showScreen(_ screen: Screen) {
        if case .landpage = screen { present(landpageController) }
        else if case .signIn = screen { present(signInController) }
        else { present(signUpController) }
    }
}
