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
//        viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
        viewDidConfigure()
    }
    
//    func viewDidLoadBehaviors() {
//        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
//                      BlackStyleNavigationBarBehavior()])
//    }
    
    func viewDidDeploySubviews() {
        createBadgeView()
    }
    
    func viewDidTargetSubviews() {
        cancelBarButton.addTarget(self, action: #selector(dismissViewController))
        saveBarButton.addTarget(self, action: #selector(saveDidTap))
        
        profileNameTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        
        onTapResignFirstResponder()
    }
    
    func viewDidConfigure() {
        configureSaveBarButton()
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

// MARK: - TextFieldDelegate Implementataion

extension AddUserProfileViewController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc
    func valueDidChange(_ textField: UITextField) {
        switch textField {
        case profileNameTextField:
            viewModel.profileName = textField.text
            
            guard textField.text?.count ?? .zero > .zero else {
                saveBarButton.isEnabled = false
                return
            }
            saveBarButton.isEnabled = true
        default:
            return
        }
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
    
    private func configureAvatarImageView() {
        avatarImageView.cornerRadius(8.0)
    }
    
    private func configureProfileNameTextField() {
        let selectedProfile = viewModel.selectedProfile?.name ?? "Profile Name"
        let color = Theme.textFieldPlaceholderTintColor
        let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: color]
        
        profileNameTextField.delegate = self
        
        profileNameTextField
            .border(color, width: 1.0)
            .cornerRadius(8.0)
            .setPlaceholderAtrributes(string: selectedProfile, attributes: attributes)
    }
    
    @objc
    private func saveDidTap() {
        let authService = Application.app.services.auth
        
        guard let profileName = viewModel.profileName,
              let user = authService.user,
              let userId = user._id
        else { return }
        
        let profileDTO = ProfileDTO(name: profileName, image: "av-dark-green", active: false, user: userId)
        let request = ProfileHTTPDTO.POST.Request(user: user, profile: profileDTO)
        
        viewModel.createUserProfile(with: request) { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.add(profileDTO.toDomain())
            self.clearChanges()
            self.dismissViewController()
            self.loadChanges()
        }
    }
    
    @objc
    private func dismissViewController() {
        dismiss(animated: true)
    }
    
    private func clearChanges() {
        saveBarButton.isEnabled = false
        
        profileNameTextField.text = .toBlank()
        profileNameTextField.resignFirstResponder()
    }
    
    private func loadChanges() {
        guard let coordinator = Application.app.coordinator.profileCoordinator,
              let controller = coordinator.userProfileController
        else { return }
        
        let layout = controller.createLayout()
        controller.collectionView?.setCollectionViewLayout(layout, animated: false)
        controller.dataSource?.dataSourceDidChange()
    }
}
