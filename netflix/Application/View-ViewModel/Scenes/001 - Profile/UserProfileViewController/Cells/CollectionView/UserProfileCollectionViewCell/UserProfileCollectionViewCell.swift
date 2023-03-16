//
//  UserProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: UserProfileCollectionViewCellViewModel, at indexPath: IndexPath)
}

private protocol ViewOutput {
    func didSelect()
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - UserProfileCollectionViewCell Type

final class UserProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var layerContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var viewModel: ProfileViewModel?
    
    static func create(in collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with viewModel: ProfileViewModel) -> UserProfileCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserProfileCollectionViewCell.reuseIdentifier,
            for: indexPath) as? UserProfileCollectionViewCell else { fatalError() }
        cell.viewModel = viewModel
        cell.tag = indexPath.row
        let model = viewModel.profiles[indexPath.row]
        let cellViewModel = UserProfileCollectionViewCellViewModel(with: model)
        cell.viewDidConfigure()
        cell.viewDidConfigure(with: cellViewModel, at: indexPath)
        cell.viewDidTargetSubviews()
        return cell
    }
    
    func viewDidConfigure() {
        button.layer.cornerRadius = 4.0
    }
    
    func viewDidTargetSubviews() {
        button.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension UserProfileCollectionViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension UserProfileCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: UserProfileCollectionViewCellViewModel, at indexPath: IndexPath) {
        guard let count = self.viewModel?.profiles.count else { return }
        
        guard indexPath.row == count - 1 else {
            let imageName = viewModel.image
            let image = UIImage(named: imageName)
            button.tag = count - 1
            button.setImage(image, for: .normal)
            button.layer.cornerRadius = 8.0
            titleLabel.text = viewModel.name
            return
        }
        
        let imageName = viewModel.image
        let imageSize: CGFloat = 40.0
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .light)
        let image = UIImage(systemName: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#cacaca"))
            .withConfiguration(symbolConfiguration)
        button.tag = indexPath.row
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 8.0
        titleLabel.text = viewModel.name
        
        layerContainer.layer.cornerRadius = 8.0
        layerContainer.layer.borderColor = UIColor.hexColor("#aaaaaa").cgColor
        layerContainer.layer.borderWidth = 1.0
    }
    
    @objc
    func didSelect() {
        guard let addProfileIndex = (viewModel?.profiles.count ?? 2) - 1 as Int? else { return }
        
        switch tag {
        case addProfileIndex:
            guard let coordinator = viewModel?.coordinator else { return }
            coordinator.coordinate(to: .addProfile)
        default:
            guard let profile = viewModel?.profiles[tag] else { return }
            print(profile.name)
            let authService = Application.app.services.authentication
            print(authService.user?.toDomain())
        }
    }
    
}
