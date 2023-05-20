//
//  TrailerCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - TrailerCollectionViewCell Type

final class TrailerCollectionViewCell: CollectionViewCell<TrailerCollectionViewCellViewModel> {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    
    override func viewDidLoad() {
        viewWillConfigure()
        
        dataWillLoad { [weak self] in
            self?.viewDidConfigure()
        }
    }
    
    override func dataWillLoad(completion: (() -> Void)?) {
        loadResources(completion)
    }
    
    override func viewWillConfigure() {
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 2.0
        playButton.layer.cornerRadius = playButton.bounds.size.height / 2
        
        posterImageView.layer.cornerRadius = 4.0
    }
    
    override func viewDidConfigure() {
        let image = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        
        posterImageView.image = image
        titleLabel.text = viewModel.title
    }
    
    override func loadResources(_ completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                mainQueueDispatch {
                    completion?()
                }
            }
    }
}
