//
//  PosterCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - PosterCollectionViewCell Type

class PosterCollectionViewCell: CollectionViewCell<PosterCollectionViewCellViewModel> {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var logoBottomConstraint: NSLayoutConstraint!
    
    override func dataWillLoad(completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                mainQueueDispatch { completion?() }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { _ in
                mainQueueDispatch { completion?() }
            }
    }
    
    override func viewDidLoad() {
        representedIdentifier = viewModel.slug as NSString
        
        setBackgroundColor(.clear)
        
        placeholderLabel.alpha = 1.0
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 4.0
        posterImageView.contentMode = .scaleAspectFill
        
        dataWillLoad { [weak self] in
            guard let self = self else { return }
            
            self.viewWillConfigure()
        }
        
        placeholderLabel.text = viewModel.title
    }
    
    override func viewWillConfigure() {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        let posterImage = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        let logoImage = AsyncImageService.shared.object(for: viewModel.logoImageIdentifier)
        posterImageView.image = posterImage
        logoImageView.image = logoImage

        placeholderLabel.alpha = .zero
        
        logoWillAlign()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.image = nil
        logoImageView.image = nil
        placeholderLabel.text = nil
        logoBottomConstraint?.constant = .zero
    }
    
    func logoWillAlign() {
        guard let constraint = logoBottomConstraint else { return }
        
        switch viewModel.presentedLogoAlignment {
        case .top: constraint.constant = bounds.maxY - logoImageView.bounds.height - 8.0
        case .midTop: constraint.constant = 64.0
        case .mid: constraint.constant = bounds.midY
        case .midBottom: constraint.constant = 24.0
        case .bottom: constraint.constant = 8.0
        }
    }
}
