//
//  EpisodeCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func dataDidDownload(with viewModel: EpisodeCollectionViewCellViewModel,
                         completion: (() -> Void)?)
    func viewDidLoad(at indexPath: IndexPath,
                     with viewModel: EpisodeCollectionViewCellViewModel)
    func viewDidConfigure(at indexPath: IndexPath,
                          with viewModel: EpisodeCollectionViewCellViewModel)
}

// MARK: - EpisodeCollectionViewCell Type

final class EpisodeCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var downloadButton: UIButton!
    
    /// Create an episode collection view cell object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: An episode collection view cell object.
    static func create(on collectionView: UICollectionView,
                       for indexPath: IndexPath,
                       with viewModel: DetailViewModel) -> EpisodeCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: EpisodeCollectionViewCell.reuseIdentifier,
            for: indexPath) as? EpisodeCollectionViewCell else { fatalError() }
        let cellViewModel = EpisodeCollectionViewCellViewModel(with: viewModel)
        view.viewDidLoad(at: indexPath, with: cellViewModel)
        return view
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension EpisodeCollectionViewCell: ViewLifecycleBehavior {
    func viewDidConfigure() {
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 2.0
        playButton.layer.cornerRadius = playButton.bounds.size.height / 2
        
        imageView.layer.cornerRadius = 4.0
    }
}

// MARK: - ViewProtocol Implementation

extension EpisodeCollectionViewCell: ViewProtocol {
    fileprivate func dataDidDownload(with viewModel: EpisodeCollectionViewCellViewModel,
                                     completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                mainQueueDispatch { completion?() }
            }
    }
    
    fileprivate func viewDidLoad(at indexPath: IndexPath,
                                 with viewModel: EpisodeCollectionViewCellViewModel) {
        dataDidDownload(with: viewModel) { [weak self] in
            self?.viewDidConfigure(at: indexPath, with: viewModel)
        }
        
        viewDidConfigure()
    }
    
    fileprivate func viewDidConfigure(at indexPath: IndexPath,
                                      with viewModel: EpisodeCollectionViewCellViewModel) {
        guard let season = viewModel.season else { return }
        let episode = season.episodes[indexPath.row]
        let image = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        imageView.image = image
        titleLabel.text = episode.title
        timestampLabel.text = viewModel.media.length
        descriptionTextView.text = viewModel.media.description
    }
}
