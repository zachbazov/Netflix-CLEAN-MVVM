//
//  DetailCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 24/05/2023.
//

import UIKit

// MARK: - DetailCollectionViewCell Type

class DetailCollectionViewCell: UICollectionViewCell, CollectionViewCell {
    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var playButton: UIButton!
    
    var viewModel: DetailCollectionViewCellViewModel!
    
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    // MARK: ViewLifecycleBehavior Implementation
    
    func viewWillConfigure() {
        playButton.border(.white, width: 2.0)
        playButton.cornerRadius(playButton.bounds.size.height / 2)
        
        imageView.cornerRadius(4.0)
    }
    
    // MARK: ViewProtocol Implementation
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    func setPoster(_ image: UIImage) {
        imageView.image = image
    }
}

// MARK: - Private Implementation

extension DetailCollectionViewCell {
    func fetchImage() {
        let imageService = Application.app.services.image
        
        imageService.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
            guard let self = self,
                  self.representedIdentifier == self.viewModel.slug as NSString?,
                  let image = image
            else { return }
            
            mainQueueDispatch {
                self.setPoster(image)
            }
        }
    }
}
