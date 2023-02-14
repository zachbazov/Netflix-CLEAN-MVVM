//
//  AuthCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - AuthCoordinatorProtocol Protocol

private protocol AuthCoordinatorProtocol {
    func deployLandpageDependencies() -> LandpageViewController
    func deploySignInDependencies() -> SignInViewController
    func deploySignUpDependencies() -> SignUpViewController
    func present(_ sender: Any)
}

// MARK: - AuthCoordinator Type

final class AuthCoordinator {
    var viewController: AuthController?
    
    private lazy var landpageController: LandpageViewController = deployLandpageDependencies()
    private lazy var signInController: SignInViewController = deploySignInDependencies()
    private lazy var signUpController: SignUpViewController = deploySignUpDependencies()
}

// MARK: - AuthCoordinatorProtocol Implementation

extension AuthCoordinator: AuthCoordinatorProtocol {
    fileprivate func deployLandpageDependencies() -> LandpageViewController {
        let controller = LandpageViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    fileprivate func deploySignInDependencies() -> SignInViewController {
        let controller = SignInViewController()
        let viewModel = SignInViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        return controller
    }
    
    fileprivate func deploySignUpDependencies() -> SignUpViewController {
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

// MARK: - Coordinate Implementation

extension AuthCoordinator: Coordinate {
    /// View representation type.
    enum Screen {
        case landpage
        case signIn
        case signUp
    }
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func deploy(screen: Screen) {
        if case .landpage = screen { return present(landpageController) }
        else if case .signIn = screen { return present(signInController) }
        present(signUpController)
    }
}
