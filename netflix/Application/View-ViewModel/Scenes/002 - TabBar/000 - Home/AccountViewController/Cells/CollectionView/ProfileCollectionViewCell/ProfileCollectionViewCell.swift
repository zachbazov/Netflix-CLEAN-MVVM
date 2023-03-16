//
//  ProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: ProfileCollectionViewCellViewModel,
                          at indexPath: IndexPath,
                          count: Int)
}

private typealias ViewProtocol = ViewInput

// MARK: - ProfileCollectionViewCell Type

final class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var layerContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    static func create(in collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with viewModel: AccountViewModel) -> ProfileCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier,
            for: indexPath) as? ProfileCollectionViewCell else { fatalError() }
        let model = viewModel.profileItems[indexPath.row]
        let cellViewModel = ProfileCollectionViewCellViewModel(with: model)
        cell.viewDidConfigure()
        cell.viewDidConfigure(with: cellViewModel, at: indexPath, count: viewModel.profileItems.count)
        return cell
    }
    
    func viewDidConfigure() {
        button.layer.cornerRadius = 4.0
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension ProfileCollectionViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension ProfileCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: ProfileCollectionViewCellViewModel,
                                      at indexPath: IndexPath,
                                      count: Int) {
        guard indexPath.row == count - 1 else {
            let imageName = viewModel.image
            let image = UIImage(named: imageName)
            button.setImage(image, for: .normal)
            titleLabel.text = viewModel.name
            return
        }
        
        let imageName = viewModel.image
        let imageSize: CGFloat = 28.0
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .bold)
        let image = UIImage(systemName: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.hexColor("#b3b3b3"))
            .withConfiguration(symbolConfiguration)
        button.setImage(image, for: .normal)
        titleLabel.text = viewModel.name
        
        layerContainer.layer.cornerRadius = 4.0
        layerContainer.layer.borderColor = UIColor.hexColor("#232323").cgColor
        layerContainer.layer.borderWidth = 2.0
    }
}
