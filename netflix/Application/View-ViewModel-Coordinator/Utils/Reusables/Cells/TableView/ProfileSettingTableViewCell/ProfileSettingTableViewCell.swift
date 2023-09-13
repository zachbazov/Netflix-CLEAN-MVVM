//
//  ProfileSettingTableViewCell.swift
//  netflix
//
//  Created by Developer on 24/08/2023.
//

import UIKit

// MARK: - ProfileSettingTableViewCellType Type

enum ProfileSettingTableViewCellType {
    case selectable
    case switchable
}

// MARK: - ProfileSettingTableViewCell Type

final class ProfileSettingTableViewCell: UITableViewCell, TableViewCell {
    @IBOutlet private weak var settingImageView: UIImageView!
    @IBOutlet private weak var headerTitle: UILabel!
    @IBOutlet private weak var optionSubtitle: UILabel!
    
    var viewModel: ProfileSettingTableViewCellViewModel!
    
    var profileViewModel: ProfileViewModel!
    
    var indexPath: IndexPath?
    
    deinit {
        viewDidDeallocate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func viewDidLoad() {
        viewDidConfigure()
    }
    
    func viewDidConfigure() {
        configureRootView()
        configureImageView()
        configureHeaderTitle()
        configureOptionSubtitle()
        configureAccessoryView()
    }
    
    func viewDidDeallocate() {
        profileViewModel = nil
        viewModel = nil
        indexPath = nil
        
        removeFromSuperview()
    }
}

// MARK: - Section Implementation

extension ProfileSettingTableViewCell {
    enum Section: Int {
        case maturityRating
        case displayLanguage
        case audioAndSubtitles
        case autoplayNextEpisode
        case autoplayPreviews
    }
}

// MARK: - UISwitchDelegate Implementation

extension ProfileSettingTableViewCell: UISwitchDelegate {
    @objc
    func switchValueDidChange(_ sender: UISwitch) {
        guard let indexPath = indexPath,
              let section = ProfileSettingTableViewCell.Section(rawValue: indexPath.section),
              var profile = profileViewModel.editingProfile
        else { return }
        
        switch section {
        case .autoplayNextEpisode:
            profile.settings?.autoplayNextEpisode = sender.isOn
        case .autoplayPreviews:
            profile.settings?.autoplayPreviews = sender.isOn
        default: break
        }
        
        profileViewModel.setEditingProfile(profile)
    }
}


// MARK: - Private Implementation

extension ProfileSettingTableViewCell {
    private func configureRootView() {
        cornerRadius(8.0)
        setBackgroundColor(UIColor.hexColor("#363636"))
        tintColor = Theme.tintColor
    }
    
    private func configureImageView() {
        settingImageView.image = UIImage(systemName: viewModel.image)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor.lightGray)
    }
    
    private func configureHeaderTitle() {
        headerTitle.text = viewModel.title
    }
    
    private func configureOptionSubtitle() {
        optionSubtitle.text = viewModel.subtitle
        optionSubtitle.hidden(viewModel.cellType == .switchable)
    }
    
    private func configureAccessoryView() {
        let chevron = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: chevron)
        let uiSwitch = UISwitch()
        
        uiSwitch.onTintColor = UIColor.hexColor("#2c6ad3")
        uiSwitch.addTarget(self, action: #selector(switchValueDidChange))
        
        guard let indexPath = indexPath,
              let section = ProfileSettingTableViewCell.Section(rawValue: indexPath.section)
        else { return }
        
        let profile = profileViewModel.editingProfile
        
        switch section {
        case .autoplayNextEpisode:
            uiSwitch.isOn = profile?.settings?.autoplayNextEpisode ?? true
        case .autoplayPreviews:
            uiSwitch.isOn = profile?.settings?.autoplayPreviews ?? true
        default: break
        }
        
        accessoryView = viewModel.cellType == .switchable ? uiSwitch : imageView
    }
}
