//
//  ProfileCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - CoordinatorProtocol Type

private protocol CoordinatorInput {
    func deploy(_ screen: ProfileCoordinator.Screen)
}

private protocol CoordinatorOutput {
    var navigationController: UINavigationController { get }
    var userProfileController: UserProfileViewController { get }
    var addUserProfileController: AddUserProfileViewController { get }
    var editUserProfileController: EditUserProfileViewController { get }
    
    func createNavigationController() -> UINavigationController
    func createUserProfileViewController() -> UserProfileViewController
    func createAddUserProfileViewController() -> AddUserProfileViewController
    func createEditUserProfileViewController() -> EditUserProfileViewController
}

private typealias CoordinatorProtocol = CoordinatorInput & CoordinatorOutput

// MARK: - ProfileCoordinator Type

final class ProfileCoordinator {
    var viewController: ProfileViewController?
    
    fileprivate lazy var navigationController: UINavigationController = createNavigationController()
    fileprivate(set) lazy var userProfileController: UserProfileViewController = createUserProfileViewController()
    fileprivate lazy var addUserProfileController: AddUserProfileViewController = createAddUserProfileViewController()
    fileprivate lazy var editUserProfileController: EditUserProfileViewController = createEditUserProfileViewController()
    
    deinit {
        print("deinit \(String(describing: Self.self))")
        viewController?.removeFromParent()
        viewController = nil
    }
}

// MARK: - CoordinatorProtocol Implementation

extension ProfileCoordinator: CoordinatorProtocol {
    fileprivate func createNavigationController() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: userProfileController)
        navigation.setNavigationBarHidden(false, animated: false)
        return navigation
    }
    
    fileprivate func createUserProfileViewController() -> UserProfileViewController {
        let controller = UserProfileViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    fileprivate func createAddUserProfileViewController() -> AddUserProfileViewController {
        let controller = AddUserProfileViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    fileprivate func createEditUserProfileViewController() -> EditUserProfileViewController {
        let controller = EditUserProfileViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    fileprivate func deploy(_ screen: Screen) {
        switch screen {
        case .userProfile:
            
            navigationController.removeFromParent()
            
            guard let view = viewController?.view else { return }
            
            viewController?.add(child: navigationController, container: view)
            
            userProfileController.present()
        case .addProfile:
            navigationController.present(addUserProfileController, animated: true)
        case .editProfile:
            navigationController.pushViewController(editUserProfileController, animated: true)
        }
    }
}

// MARK: - Coordinate Implementation

extension ProfileCoordinator: Coordinate {
    /// Screen representation type.
    enum Screen {
        case userProfile
        case addProfile
        case editProfile
    }
    
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        deploy(screen)
    }
}
