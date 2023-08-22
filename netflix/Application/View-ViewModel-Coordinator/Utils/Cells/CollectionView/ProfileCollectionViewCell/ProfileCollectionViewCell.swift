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
    
    deinit {
        viewWillDeallocate()
    }
    
    func viewDidLoad() {
        viewDidConfigure()
        viewDidTargetSubviews()
    }
    
    func viewDidConfigure() {
        button.cornerRadius(4.0)
        
        guard let profiles = profileViewModel?.profiles else { return }
        
        guard indexPath.row == profiles.count - 1 else {
            return configureProfileButtons()
        }
        
        configureAddProfileButton()
    }
    
    func viewDidTargetSubviews() {
        button.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
    }
    
    func viewWillDeallocate() {
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
        let addProfileIndex = profileViewModel.profiles.count - 1
        
        switch tag {
        case addProfileIndex:
            profileViewModel?.coordinator?.coordinate(to: .addProfile)
        default:
            userProfileUpdateSession()
        }
    }
}

// MARK: - Private Implementation

extension ProfileCollectionViewCell {
    private func configureProfileButtons() {
        let imageName = viewModel.image
        let image = UIImage(named: imageName)
        
        button.setImage(image, for: .normal)
        button.cornerRadius(8.0)
        setTitle(viewModel.name)
    }
    
    private func configureAddProfileButton() {
        let imageName = viewModel.image
        let imageSize: CGFloat = 40.0
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .light)
        let image = UIImage(systemName: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#cacaca"))
            .withConfiguration(symbolConfiguration)
        
        button.setImage(image, for: .normal)
        button.cornerRadius(8.0)
        setTitle("Add Profile")
        
        layerContainer.cornerRadius(8.0)
        layerContainer.border(.hexColor("#aaaaaa"), width: 1.0)
    }
    
    private func userProfileUpdateSession() {
        let profile = profileViewModel.profiles[tag]
        
        profileViewModel.selectedProfile = profile
        
        guard let id = profile._id else { return }
        
        profileViewModel.updateUserProfile(with: id) {
            mainQueueDispatch {
                let coordinator = Application.app.coordinator
                coordinator.coordinate(to: .tabBar)
            }
        }
    }
}
