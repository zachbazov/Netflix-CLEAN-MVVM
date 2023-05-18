//
//  EpisodeCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - EpisodeCollectionViewCell Type

final class EpisodeCollectionViewCell: Cell<EpisodeCollectionViewCellViewModel> {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var downloadButton: UIButton!
    
    override func viewDidLoad() {
        viewWillConfigure()
        
        dataWillLoad { [weak self] in self?.viewDidConfigure() }
    }
    
    override func dataWillLoad(completion: (() -> Void)?) {
        loadResources(completion)
    }
    
    override func viewDidConfigure() {
        guard let season = viewModel.season else { return }
        
        let episode = season.episodes[indexPath.row]
        let image = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        
        imageView.image = image
        titleLabel.text = episode.title
        timestampLabel.text = viewModel.media.length
        descriptionTextView.text = viewModel.media.description
    }
    
    override func viewWillConfigure() {
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 2.0
        playButton.layer.cornerRadius = playButton.bounds.size.height / 2
        
        imageView.layer.cornerRadius = 4.0
    }
    
    override func loadResources(_ completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                mainQueueDispatch { completion?() }
            }
    }
}
