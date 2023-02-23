//
//  AuthCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorInput {
    func createNavigationController(rootViewController: UIViewController) -> NavigationController
    
    func deploy(_ sender: Any)
}

private protocol CoordinatorOutput {
    var navigationController: NavigationController { get }
    var landpageController: LandpageViewController { get }
    var signInController: SignInViewController { get }
    var signUpController: SignUpViewController { get }
    
    func createLandpageController() -> LandpageViewController
    func createSignInController() -> SignInViewController
    func createSignUpController() -> SignUpViewController
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - AuthCoordinator Type

final class AuthCoordinator {
    var viewController: AuthController?
    
    fileprivate lazy var navigationController: NavigationController = createNavigationController(rootViewController: landpageController)
    fileprivate lazy var landpageController: LandpageViewController = createLandpageController()
    fileprivate(set) lazy var signInController: SignInViewController = createSignInController()
    fileprivate(set) lazy var signUpController: SignUpViewController = createSignUpController()
}

// MARK: - CoordinatorProtocol Implementation

extension AuthCoordinator: CoordinatorProtocol {
    fileprivate func createNavigationController(rootViewController: UIViewController) -> NavigationController {
        return NavigationController(rootViewController: rootViewController)
    }
    
    fileprivate func createLandpageController() -> LandpageViewController {
        let controller = LandpageViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    fileprivate func createSignInController() -> SignInViewController {
        let controller = SignInViewController()
        let viewModel = SignInViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        return controller
    }
    
    fileprivate func createSignUpController() -> SignUpViewController {
        let controller = SignUpViewController()
        let viewModel = SignUpViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        return controller
    }
    /// Push or present a new controller to the navigation stack.
    /// - Parameter sender: The object that's been interacted with.
    @objc
    func deploy(_ sender: Any) {
        switch sender {
        case is LandpageViewController:
            viewController?.present(navigationController, animated: true)
        case is UIBarButtonItem:
            navigationController.pushViewController(signInController, animated: true)
        case is UIButton:
            navigationController.pushViewController(signUpController, animated: true)
        default: break
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
    func coordinate(to screen: Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            switch screen {
            case .landpage: self.deploy(self.landpageController)
            case .signIn: self.deploy(self.signInController)
            case .signUp: self.deploy(self.signUpController)
            }
        }
    }
}
