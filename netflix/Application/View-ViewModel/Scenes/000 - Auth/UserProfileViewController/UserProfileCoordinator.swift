//
//  UserProfileCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorInput {
    func deploy(_ screen: UserProfileCoordinator.Screen)
}

private protocol CoordinatorOutput {
    var userProfile: UINavigationController? { get }
    
    func createUserProfileNavigationController() -> UINavigationController
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - UserProfileCoordinator Type

final class UserProfileCoordinator {
    var viewController: UserProfileViewController?
    
    lazy var userProfile: UINavigationController? = createUserProfileNavigationController()
}

// MARK: - CoordinatorProtocol Implementation

extension UserProfileCoordinator: CoordinatorProtocol {
    fileprivate func createUserProfileNavigationController() -> UINavigationController {
        let coordinator = UserProfileCoordinator()
        let viewModel = UserProfileViewModel()
        let controller = UserProfileViewController()
        
        controller.viewModel = viewModel
        controller.viewModel?.coordinator = coordinator
        coordinator.viewController = controller
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(false, animated: false)
        return navigation
    }
    
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .userProfile:
            guard let userProfile = userProfile, let view = viewController?.view else { return }
            viewController?.add(child: userProfile, container: view)
            
//            guard let userProfileViewController = userProfile.viewControllers.first as? UserProfileViewController else { return }
//            userProfileViewController.present()
        }
    }
}

// MARK: - Coordinate Implementation

extension UserProfileCoordinator: Coordinate {
    /// Screen representation type.
    enum Screen {
        case userProfile
    }
    
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
//        switch screen {
//        case .userProfile: userProfile = createUserProfileNavigationController()
//        }
        
        deploy(screen)
    }
}
