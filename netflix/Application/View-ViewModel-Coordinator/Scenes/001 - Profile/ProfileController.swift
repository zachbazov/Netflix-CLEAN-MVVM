//
//  ProfileController.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - ProfileController Type

final class ProfileController: UIViewController, Controller {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.preferredStatusBarStyle
    }
    
    var viewModel: ProfileViewModel!
}
