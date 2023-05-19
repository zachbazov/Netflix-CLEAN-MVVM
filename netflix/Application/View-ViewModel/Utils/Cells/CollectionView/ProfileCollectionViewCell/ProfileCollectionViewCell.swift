//
//  ProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var accountViewModel: AccountViewModel? { get }
    
    func setTitle(_ string: String)
}

// MARK: - ProfileCollectionViewCell Type

final class ProfileCollectionViewCell: CollectionViewCell<ProfileCollectionViewCellViewModel> {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var layerContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var accountViewModel: AccountViewModel?
    
    deinit {
        print("deinit \(Self.self)")
        
        accountViewModel = nil
        
        removeFromSuperview()
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
    }
    
    override func viewWillConfigure() {
        guard let profiles = accountViewModel?.profiles.value else { return }
        
        guard indexPath.row == profiles.count - 1 else {
            configureProfileButtons()
            
            return
        }
        
        configureAddProfileButton()
    }
}

// MARK: - ViewProtocol Implementation

extension ProfileCollectionViewCell: ViewProtocol {
    fileprivate func setTitle(_ string: String) {
        titleLabel.text = string
    }
}

// MARK: - Private Presentation Implementation

extension ProfileCollectionViewCell {
    private func configureProfileButtons() {
        let imageName = viewModel.image
        let image = UIImage(named: imageName)
        
        button.tag = indexPath.row
        button.setImage(image, for: .normal)
        button.cornerRadius(8.0)
        
        titleLabel.text = viewModel.name
    }
    
    private func configureAddProfileButton() {
        guard let profiles = accountViewModel?.profiles.value else { return }
        
        let imageName = viewModel.image
        let imageSize: CGFloat = 40.0
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .light)
        let image = UIImage(systemName: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#cacaca"))
            .withConfiguration(symbolConfiguration)
        
        button.tag = profiles.count - 1
        button.setImage(image, for: .normal)
        button.cornerRadius(8.0)
        
        setTitle(viewModel.name)
        
        layerContainer.cornerRadius(8.0)
        layerContainer.border(.hexColor("#aaaaaa"), width: 1.0)
    }
}
