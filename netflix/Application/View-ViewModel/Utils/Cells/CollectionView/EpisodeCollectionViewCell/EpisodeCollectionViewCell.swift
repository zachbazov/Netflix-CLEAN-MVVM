//
//  EpisodeCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - EpisodeCollectionViewCell Type

final class EpisodeCollectionViewCell: CollectionViewCell<EpisodeCollectionViewCellViewModel> {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var downloadButton: UIButton!
    
    // MARK: ViewLifecycleBehavior Implementation
    
    override func dataWillLoad() {
        guard representedIdentifier == viewModel.media.slug as NSString? else { return }
        
        if #available(iOS 13.0, *) {
            loadUsingAsyncAwait()
            
            return
        }
        
        loadUsingAsync()
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
        dataWillLoad()
    }
    
    override func viewWillConfigure() {
        playButton.border(.white, width: 2.0)
        playButton.cornerRadius(playButton.bounds.size.height / 2)
        
        imageView.cornerRadius(4.0)
        
        setTimestamp(viewModel.media.length)
        setDescription(viewModel.media.description)
        
        guard let season = viewModel.season else { return }
        let episode = season.episodes[indexPath.row]
        setTitle(episode.title)
    }
    
    // MARK: CollectionViewCellResourcing Implementation
    
    override func loadUsingAsync() {
        posterWillLoad()
    }
    
    override func loadUsingAsyncAwait() {
        Task {
            await posterWillLoad()
        }
    }
    
    // MARK: ViewProtocol Implementation
    
    override func setTimestamp(_ text: String) {
        timestampLabel.text = text
    }
    
    override func setDescription(_ text: String) {
        descriptionTextView.text = text
    }
    
    override func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    override func setPoster(_ image: UIImage) {
        imageView.image = image
    }
}

// MARK: - Private Implementation

extension EpisodeCollectionViewCell {
    private func posterWillLoad() {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setPoster(image)
                }
            }
    }
    
    private func posterWillLoad() async {
        let url = viewModel.posterImageURL
        let identifier = viewModel.posterImageIdentifier as String
        
        guard let image = await AsyncImageService.shared.load(url: url, identifier: identifier) else { return }
        
        setPoster(image)
    }
}
