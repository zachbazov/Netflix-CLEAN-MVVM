//
//  DetailCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 24/05/2023.
//

import UIKit

// MARK: - DetailCollectionViewCell Type

class DetailCollectionViewCell: CollectionViewCell<DetailCollectionViewCellViewModel> {
    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var playButton: UIButton!
    
    // MARK: ViewLifecycleBehavior Implementation
    
    override func dataWillLoad() {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        if #available(iOS 13.0, *) {
            loadUsingAsyncAwait()
            
            return
        }
        
        loadUsingAsync()
    }
    
    override func viewWillConfigure() {
        playButton.border(.white, width: 2.0)
        playButton.cornerRadius(playButton.bounds.size.height / 2)
        
        imageView.cornerRadius(4.0)
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
    
    override func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    override func setPoster(_ image: UIImage) {
        imageView.image = image
    }
}

// MARK: - Private Implementation

extension DetailCollectionViewCell {
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