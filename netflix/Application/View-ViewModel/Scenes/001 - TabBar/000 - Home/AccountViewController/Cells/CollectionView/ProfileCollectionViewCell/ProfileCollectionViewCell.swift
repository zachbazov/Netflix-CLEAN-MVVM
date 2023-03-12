//
//  ProfileCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!
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
        imageView.layer.cornerRadius = 4.0
//        layerContainer.translatesAutoresizingMaskIntoConstraints = false
        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: layerContainer.topAnchor, constant: 32),
//            imageView.leadingAnchor.constraint(equalTo: layerContainer.leadingAnchor, constant: 32),
//            imageView.trailingAnchor.constraint(equalTo: layerContainer.trailingAnchor, constant: 32),
//            imageView.bottomAnchor.constraint(equalTo: layerContainer.bottomAnchor, constant: 32)
//        ])
    }
    
    func viewDidConfigure(with viewModel: ProfileCollectionViewCellViewModel,
                          at indexPath: IndexPath,
                          count: Int) {
        if indexPath.row == count - 1 {
            let imageName = viewModel.image
            imageView.contentMode = .scaleAspectFit
//            imageView.translatesAutoresizingMaskIntoConstraints = false
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16.0)
            imageView.image = UIImage(systemName: imageName)?.whiteRendering(with: symbolConfiguration)
//                .withRenderingMode(.alwaysOriginal)
//                .withTintColor(.hexColor("#b3b3b3"))
            imageView.frame = .zero
            
//            layerContainer.layer.cornerRadius = 4.0
//            layerContainer.layer.borderColor = UIColor.hexColor("#121212").cgColor
//            layerContainer.layer.borderWidth = 2.0
        } else {
            let imageName = viewModel.image
            let image = UIImage(named: imageName)
            imageView.image = image
        }
        
        titleLabel.text = viewModel.name
    }
}

extension ProfileCollectionViewCell: ViewLifecycleBehavior {}
