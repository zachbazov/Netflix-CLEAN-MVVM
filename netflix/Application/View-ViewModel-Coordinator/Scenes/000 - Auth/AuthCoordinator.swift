//
//  AuthCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - AuthCoordinator Type

final class AuthCoordinator {
    var viewController: AuthController?
    
    lazy var navigationController: NavigationController? = createNavigationController()
    lazy var landpageController: LandpageViewController? = createLandpageController()
    var signInController: SignInViewController?
    var signUpController: SignUpViewController?
    
    func removeViewControllers() {
        navigationController?.viewControllers.forEach { $0.removeFromParent() }
        navigationController?.removeFromParent()
        navigationController = nil
        
        viewController?.removeFromParent()
        viewController?.viewModel.coordinator = nil
        viewController?.viewModel = nil
        viewController = nil
        
        landpageController = nil
        signInController = nil
        signUpController = nil
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
            
            switch screen {
            case .landpage:
                guard let navigationController = self.navigationController else { return }
                self.viewController?.present(navigationController, animated: true)
            case .signIn:
                self.signInController = self.createSignInController()
                
                guard let signInController = self.signInController else { return }
                self.navigationController?.pushViewController(signInController, animated: true)
            case .signUp:
                self.signUpController = self.createSignUpController()
                
                guard let signUpController = self.signUpController else { return }
                self.navigationController?.pushViewController(signUpController, animated: true)
            default: break
            }
        }
    }
}

// MARK: - Private Implementation

extension AuthCoordinator {
    private func createNavigationController() -> NavigationController {
        guard let landpageController = landpageController else { fatalError() }
        return NavigationController(rootViewController: landpageController)
    }
    
    private func createLandpageController() -> LandpageViewController {
        let controller = LandpageViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    private func createSignInController() -> SignInViewController {
        let controller = SignInViewController()
        let viewModel = SignInViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        controller.viewModel.coordinator = self
        return controller
    }
    
    private func createSignUpController() -> SignUpViewController {
        let controller = SignUpViewController()
        let viewModel = SignUpViewModel(with: viewController!.viewModel)
        controller.viewModel = viewModel
        controller.viewModel.coordinator = self
        return controller
    }
}
