//
//  EditUserProfileViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/03/2023.
//

import UIKit

// MARK: - EditUserProfileViewController Type

final class EditUserProfileViewController: UIViewController, Controller {
    @IBOutlet private weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet private weak var doneBarButton: UIBarButtonItem!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var badgeViewContainer: UIView!
    @IBOutlet private weak var profileNameTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!
    
    var viewModel: ProfileViewModel!
    
    private var badgeView: BadgeView?
    private var dataSource: ProfileSettingTableViewDataSource?
    
    deinit {
        viewDidDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidConfigure()
    }
    
    func viewDidDeploySubviews() {
        createBadgeView()
        createDataSource()
    }
    
    func viewDidTargetSubviews() {
        profileNameTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        
        cancelBarButton.addTarget(self, action: #selector(cancelDidTap))
        doneBarButton.addTarget(self, action: #selector(doneDidTap))
        
        onTapResignFirstResponder()
    }
    
    func viewDidConfigure() {
        configureAvatarImageView()
        configureProfileNameTextField()
        configureTableView()
    }
    
    func viewDidDeallocate() {
        badgeView?.removeFromSuperview()
        badgeView = nil
        
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - TextFieldDelegate Implementation

extension EditUserProfileViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc
    func valueDidChange(_ textField: UITextField) {
        switch textField {
        case profileNameTextField:
            viewModel.editingProfile?.name = textField.text?.trimmingCharacters(in: .whitespaces) ?? .toBlank()
        default:
            return
        }
    }
}

// MARK: - Private Implementation

extension EditUserProfileViewController {
    private func createBadgeView() {
        let badge = Badge(badgeType: .edit)
        badgeView = BadgeView(on: badgeViewContainer, badge: badge)
    }
    
    private func createDataSource() {
        dataSource = ProfileSettingTableViewDataSource(with: viewModel)
    }
    
    private func configureAvatarImageView() {
        guard let editingProfile = viewModel.editingProfile else { return }
        
        profileImageView.image = UIImage(named: editingProfile.image)
        profileImageView.cornerRadius(8.0)
    }
    
    private func configureProfileNameTextField() {
        let editingProfileName = viewModel.editingProfile?.name ?? "Profile Name"
        let color = Theme.textFieldPlaceholderTintColor
        let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: color]
        
        profileNameTextField.delegate = self
        
        profileNameTextField
            .border(color, width: 1.0)
            .cornerRadius(8.0)
            .setTextAtrributes(string: editingProfileName, attributes: attributes)
    }
    
    private func configureTableView() {
        tableView.setBackgroundColor(.clear)
        
        let profileSettingsCount = viewModel.profileSettings.count.cgFloat
        tableViewHeight.constant = 64.0 * profileSettingsCount + 8.0 * profileSettingsCount
        
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    @objc
    private func cancelDidTap() {
        dismissViewController()
    }
    
    @objc
    private func doneDidTap() {
        let authService = Application.app.services.auth
        
        guard let userDTO = authService.user,
              let profile = viewModel.editingProfile
        else { return }
        
        let request = ProfileHTTPDTO.PATCH.Request(user: userDTO,
                                                   id: profile.toDTO()._id,
                                                   profile: profile.toDTO())
        
        viewModel.updateUserProfile(with: request) { [weak self] in
            guard let self = self else { return }
            
            let request = ProfileHTTPDTO.Settings.PATCH.Request(
                user: userDTO,
                id: profile.settings?._id ?? .toBlank(),
                settings: profile.settings?.toDTO() ?? .defaultValue)
            
            viewModel.updateUserProfileSettings(with: request) {
                guard let userProfileController = self.viewModel.coordinator?.userProfileController else { return }
                
                userProfileController.editDidTap()
                userProfileController.dataSource?.dataSourceDidChange()
                
                self.dismissViewController()
            }
        }
    }
    
    private func dismissViewController() {
        dismiss(animated: true)
    }
}
