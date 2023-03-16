//
//  UserProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: UserProfileCollectionViewCellViewModel,
                          at indexPath: IndexPath,
                          count: Int)
}

private typealias ViewProtocol = ViewInput

// MARK: - UserProfileCollectionViewCell Type

final class UserProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var layerContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    static func create(in collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with viewModel: ProfileViewModel) -> UserProfileCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserProfileCollectionViewCell.reuseIdentifier,
            for: indexPath) as? UserProfileCollectionViewCell else { fatalError() }
        let model = viewModel.profiles[indexPath.row]
        let cellViewModel = UserProfileCollectionViewCellViewModel(with: model)
        cell.viewDidConfigure()
        cell.viewDidConfigure(with: cellViewModel, at: indexPath, count: viewModel.profiles.count)
        return cell
    }
    
    func viewDidConfigure() {
        button.layer.cornerRadius = 4.0
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension UserProfileCollectionViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension UserProfileCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: UserProfileCollectionViewCellViewModel,
                                      at indexPath: IndexPath,
                                      count: Int) {
        guard indexPath.row == count - 1 else {
            let imageName = viewModel.image
            let image = UIImage(named: imageName)
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
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 8.0
        titleLabel.text = viewModel.name
        
        layerContainer.layer.cornerRadius = 8.0
        layerContainer.layer.borderColor = UIColor.hexColor("#aaaaaa").cgColor
        layerContainer.layer.borderWidth = 1.0
    }
}

