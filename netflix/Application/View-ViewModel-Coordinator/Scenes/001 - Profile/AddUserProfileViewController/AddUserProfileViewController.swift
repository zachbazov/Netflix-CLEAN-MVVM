//
//  AddUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - AddUserProfileViewController Type

final class AddUserProfileViewController: UIViewController, Controller {
    @IBOutlet private weak var navigationTitleLabel: UINavigationItem!
    @IBOutlet private weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet private weak var saveBarButton: UIBarButtonItem!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var profileNameTextField: UITextField!
    @IBOutlet private weak var kidsActivationSwitch: UISwitch!
    @IBOutlet private weak var badgeViewContainer: UIView!
    
    private var badgeView: BadgeView?
    
    var viewModel: ProfileViewModel!
    
    deinit {
        viewDidDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidConfigure()
    }
    
    func viewDidDeploySubviews() {
        createBadgeView()
    }
    
    func viewDidConfigure() {
        configureSaveBarButton()
        configureCancelBarButton()
        configureAvatarImageView()
        configureProfileNameTextField()
    }
    
    func viewDidDeallocate() {
        badgeView?.removeFromSuperview()
        badgeView = nil
        
        viewModel = nil
            
        removeFromParent()
    }
}

// MARK: - Private Implementation

extension AddUserProfileViewController {
    private func createBadgeView() {
        let badge = Badge(badgeType: .edit)
        badgeView = BadgeView(on: badgeViewContainer, badge: badge)
    }
    
    private func configureSaveBarButton() {
        saveBarButton.isEnabled = false
    }
    
    private func configureCancelBarButton() {
        cancelBarButton.addTarget(self, action: #selector(dismissViewController))
    }
    
    private func configureAvatarImageView() {
        avatarImageView.cornerRadius(8.0)
    }
    
    private func configureProfileNameTextField() {
        let selectedProfile = viewModel.selectedProfile?.name ?? "Profile Name"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.hexColor("#CACACA")]
        let color = UIColor.hexColor("#CACACA")
        
        profileNameTextField
            .border(color, width: 1.0)
            .cornerRadius(8.0)
            .setPlaceholderAtrributes(string: selectedProfile, attributes: attributes)
    }
    
    @objc
    private func dismissViewController() {
        dismiss(animated: true)
    }
}
