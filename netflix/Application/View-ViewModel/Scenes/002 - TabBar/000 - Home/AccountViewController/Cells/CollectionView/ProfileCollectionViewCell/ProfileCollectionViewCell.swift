//
//  ProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: ProfileCollectionViewCellViewModel, at indexPath: IndexPath)
}

private typealias ViewProtocol = ViewInput

// MARK: - ProfileCollectionViewCell Type

final class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var layerContainer: UIView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var viewModel: AccountViewModel?
    
    deinit {
        print("deinit \(String(describing: Self.self))")
    }
    
    static func create(in collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with viewModel: AccountViewModel) -> ProfileCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier,
            for: indexPath) as? ProfileCollectionViewCell else { fatalError() }
        cell.viewModel = viewModel
        let model = viewModel.profiles.value.toProfileItems()[indexPath.row]
        let cellViewModel = ProfileCollectionViewCellViewModel(with: model)
        cell.viewDidConfigure()
        cell.viewDidConfigure(with: cellViewModel, at: indexPath)
        return cell
    }
    
    func viewDidConfigure() {
        button.layer.cornerRadius = 4.0
    }
}
extension Array where Element == UserProfile {
    func toProfileItems() -> [ProfileItem] {
        return map { ProfileItem(image: $0.image, name: $0.name) }
    }
}
// MARK: - ViewLifecycleBehavior Implementation

extension ProfileCollectionViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension ProfileCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: ProfileCollectionViewCellViewModel, at indexPath: IndexPath) {
        guard let count = self.viewModel?.profiles.value.count else { return }
        
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
}
