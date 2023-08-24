//
//  EditUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - EditUserProfileViewController Type

final class EditUserProfileViewController: UIViewController, Controller {
    var viewModel: ProfileViewModel!
    
    deinit {
        printIfDebug(.debug, "deinit")
        viewModel = nil
        
        removeFromParent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidConfigure()
    }
    
    func viewDidConfigure() {
        setTitle()
    }
}

// MARK: - Private Implementation

extension EditUserProfileViewController {
    private func setTitle() {
        guard let profileName = viewModel.editingProfile?.name else { return }
        title = profileName
    }
}
