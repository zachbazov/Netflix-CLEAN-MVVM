//
//  ProfileCoordinator.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - ProfileCoordinator Type

final class ProfileCoordinator {
    var viewController: ProfileController?
    
    lazy var navigationController: UINavigationController? = createNavigationController()
    lazy var userProfileController: UserProfileViewController? = createUserProfileViewController()
    lazy var addUserProfileController: AddUserProfileViewController? = createAddUserProfileViewController()
    lazy var editUserProfileController: EditUserProfileViewController? = createEditUserProfileViewController()
    
    func removeViewControllers() {
        navigationController?.viewControllers.forEach { $0.removeFromParent() }
        navigationController?.removeFromParent()
        navigationController = nil
        addUserProfileController = nil
        editUserProfileController = nil
        userProfileController = nil
        
        viewController?.viewModel = nil
        viewController?.removeFromParent()
        viewController = nil
    }
}

// MARK: - Coordinator Implementation

extension ProfileCoordinator: Coordinator {
    /// Screen representation type.
    enum Screen {
        case userProfile
        case addProfile
        case editProfile
    }
    
    /// Screen representation control.
    /// - Parameter screen: The screen to be allocated and presented.
    func coordinate(to screen: Screen) {
        switch screen {
        case .userProfile:
            guard let navigationController = navigationController else { return }
            
            navigationController.removeFromParent()
            
            guard let view = viewController?.view else { return }
            
            viewController?.add(child: navigationController, container: view)
            
            userProfileController?.present()
        case .addProfile:
            guard let addUserProfileController = addUserProfileController else { fatalError() }
            navigationController?.present(addUserProfileController, animated: true)
        case .editProfile:
            guard let editUserProfileController = editUserProfileController else { fatalError() }
            navigationController?.pushViewController(editUserProfileController, animated: true)
        }
    }
}

// MARK: - Private Implementation

extension ProfileCoordinator {
    private func createNavigationController() -> UINavigationController {
        guard let userProfileController = userProfileController else { fatalError() }
        let navigation = UINavigationController(rootViewController: userProfileController)
        navigation.setNavigationBarHidden(false, animated: false)
        return navigation
    }
    
    private func createUserProfileViewController() -> UserProfileViewController {
        let controller = UserProfileViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    private func createAddUserProfileViewController() -> AddUserProfileViewController {
        let controller = AddUserProfileViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
    
    private func createEditUserProfileViewController() -> EditUserProfileViewController {
        let controller = EditUserProfileViewController()
        controller.viewModel = viewController?.viewModel
        return controller
    }
}
