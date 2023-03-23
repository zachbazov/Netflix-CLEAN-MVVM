//
//  TrailerCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func dataDidDownload(with viewModel: TrailerCollectionViewCellViewModel,
                         completion: (() -> Void)?)
    func viewDidConfigure(with viewModel: TrailerCollectionViewCellViewModel)
    func viewDidLoad(with viewModel: TrailerCollectionViewCellViewModel)
}

// MARK: - TrailerCollectionViewCell Type

final class TrailerCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    
    /// Create a trailer collection view cell object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A trailer collection view cell.
    static func create(on collectionView: UICollectionView,
                       for indexPath: IndexPath,
                       with viewModel: DetailViewModel) -> TrailerCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrailerCollectionViewCell.reuseIdentifier,
            for: indexPath) as? TrailerCollectionViewCell else { fatalError() }
        let cellViewModel = TrailerCollectionViewCellViewModel(with: viewModel.media)
        view.viewDidLoad(with: cellViewModel)
        return view
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension TrailerCollectionViewCell: ViewLifecycleBehavior {
    func viewDidConfigure() {
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 2.0
        playButton.layer.cornerRadius = playButton.bounds.size.height / 2
        
        posterImageView.layer.cornerRadius = 4.0
    }
}

// MARK: - ViewProtocol Implementation

extension TrailerCollectionViewCell: ViewProtocol {
    fileprivate func dataDidDownload(with viewModel: TrailerCollectionViewCellViewModel,
                                 completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in completion?() }
    }
    
    fileprivate func viewDidLoad(with viewModel: TrailerCollectionViewCellViewModel) {
        dataDidDownload(with: viewModel) { [weak self] in
            DispatchQueue.main.async { self?.viewDidConfigure(with: viewModel) }
        }
        
        viewDidConfigure()
    }
    
    fileprivate func viewDidConfigure(with viewModel: TrailerCollectionViewCellViewModel) {
        let image = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        posterImageView.image = image
        titleLabel.text = viewModel.title
    }
}
