//
//  ProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/03/2023.
//

import UIKit

// MARK: - ProfileCollectionViewCell Type

final class ProfileCollectionViewCell: UICollectionViewCell, CollectionViewCell {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var layerContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var profileViewModel: ProfileViewModel!
    var viewModel: ProfileCollectionViewCellViewModel!
    
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    var editOverlayView: EditOverlayView?
    
    deinit {
        viewDidDeallocate()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewDidDeploySubviews()
        viewDidConfigure()
        viewDidTargetSubviews()
    }
    
    func viewDidDeploySubviews() {
        createEditOverlayView()
    }
    
    func viewDidConfigure() {
        configureButtons()
    }
    
    func viewDidTargetSubviews() {
        button.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
    }
    
    func viewDidDeallocate() {
        editOverlayView?.removeFromSuperview()
        editOverlayView = nil
        
        representedIdentifier = nil
        indexPath = nil
        profileViewModel = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - CollectionViewCellConfiguring Implementation

extension ProfileCollectionViewCell: CollectionViewCellConfiguring {
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}

// MARK: - CollectionViewCellEditable Implementation

extension ProfileCollectionViewCell: CollectionViewCellEditable {
    func editMode(_ active: Bool) {
        editOverlayView?.foreground?.hidden(!active)
    }
}

// MARK: - ThemeUpdatable Implementation

extension ProfileCollectionViewCell: ThemeUpdatable {
    func updateWithTheme() {
        titleLabel.textColor = Theme.tintColor
    }
}

// MARK: - Internal Implementation

extension ProfileCollectionViewCell {
    @objc
    func didSelect() {
        let addProfileIndex = profileViewModel.profiles.lastIndex
        
        switch tag {
        case addProfileIndex:
            profileViewModel?.coordinator?.coordinate(to: .addProfile)
        default:
            updateUserProfileSession()
        }
    }
    
    @objc
    private func didSelectItemForEditing() {
        profileViewModel?.editingProfile = profileViewModel.profiles[tag]
        profileViewModel?.profileIndex = tag
        
        profileViewModel?.coordinator?.coordinate(to: .editProfile)
    }
}

// MARK: - Private Implementation

extension ProfileCollectionViewCell {
    private func createEditOverlayView() {
        editOverlayView = EditOverlayView(on: button)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectItemForEditing))
        editOverlayView?.foreground?.addGestureRecognizer(tap)
    }
    
    private func configureButtons() {
        button.cornerRadius(8.0)
        layerContainer.cornerRadius(8.0)
        
        setTitle(viewModel.name)
        
        if viewModel.name == "Add Profile" {
            return configureAddProfileButton()
        }
        
        configureProfileButtons()
    }
    
    private func configureProfileButtons() {
        let imageName = viewModel.image
        let image = UIImage(named: imageName)
        
        button.setImage(image, for: .normal)
    }
    
    private func configureAddProfileButton() {
        let pointSize: CGFloat = 40.0
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .light)
        let image = UIImage.plus(withSymbolConfiguration: symbolConfiguration)
        
        button.setImage(image, for: .normal)
        layerContainer.border(.hexColor("#aaaaaa"), width: 1.0)
    }
    
    private func updateUserProfileSession() {
        let profile = profileViewModel.profiles[tag]
        
        profileViewModel.selectedProfile = profile
        
        guard let id = profile._id else { return }
        
        profileViewModel.updateUserSelectedProfile(with: id) {
            
            mainQueueDispatch {
                let coordinator = Application.app.coordinator
                coordinator.coordinate(to: .tabBar)
            }
        }
    }
}
