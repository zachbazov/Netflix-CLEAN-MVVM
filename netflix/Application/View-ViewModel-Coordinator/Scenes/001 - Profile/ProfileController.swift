//
//  ProfileController.swift
//  netflix
//
//  Created by Zach Bazov on 14/03/2023.
//

import UIKit

// MARK: - ProfileController Type

final class ProfileController: UIViewController, Controller {
    var viewModel: ProfileViewModel!
    
    deinit {
        print("deinit \(String(describing: Self.self))")
        viewModel.coordinator = nil
        viewModel = nil
    }
}
