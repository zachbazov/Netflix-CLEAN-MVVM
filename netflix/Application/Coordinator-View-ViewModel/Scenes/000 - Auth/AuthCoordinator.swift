//
//  AuthCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorProtocol {
    var navigationController: NavigationController { get }
    var landpageController: LandpageViewController { get }
    var signInController: SignInViewController { get }
    var signUpController: SignUpViewController { get }
    
    func createNavigationController() -> NavigationController
    func createLandpageController() -> LandpageViewController
    func createSignInController() -> SignInViewController
    func createSignUpController() -> SignUpViewController
    
    func deploy(_ screen: AuthCoordinator.Screen)
}

// MARK: - AuthCoordinator Type

final class AuthCoordinator {
    var viewController: AuthController?
    
    fileprivate(set) lazy var navigationController: NavigationController = createNavigationController()
    fileprivate lazy var landpageController: LandpageViewController = createLandpageController()
    fileprivate(set) lazy var signInController: SignInViewController = createSignInController()
    fileprivate(set) lazy var signUpController: SignUpViewController = createSignUpController()
}

// MARK: - CoordinatorProtocol Implementation

extension AuthCoordinator: CoordinatorProtocol {
    fileprivate func createNavigationController() -> NavigationController {
        return NavigationController(rootViewController: landpageController)
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
        controller.viewModel.coordinator = self
        return controller
    }
    
    fileprivate func createSignUpController() -> SignUpViewController {
        let controller = SignUpViewController()
        let viewModel = SignUpViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        controller.viewModel.coordinator = self
        return controller
    }
    
    /// Push or present a new controller to the navigation stack.
    /// - Parameter sender: The object that's been interacted with.
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .landpage:
            viewController?.present(navigationController, animated: true)
        case .signIn:
            navigationController.pushViewController(signInController, animated: true)
        case .signUp:
            navigationController.pushViewController(signUpController, animated: true)
        default: break
        }
    }
}

// MARK: - Coordinator Implementation

extension AuthCoordinator: Coordinator {
    /// View representation type.
    @objc
    enum Screen: Int {
        case landpage = 0
        case signIn
        case signUp
    }
    
    /// Screen presentation control.
    /// - Parameter screen: The screen to be allocated and presented.
    @objc
    func coordinate(to screen: Screen) {
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            self.deploy(screen)
        }
    }
}
