//
//  SearchCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func setPoster(_ image: UIImage)
    func setLogo(_ image: UIImage)
    func setTitle(_ string: String)
}

// MARK: - SearchCollectionViewCell Type

final class SearchCollectionViewCell: CollectionViewCell<SearchCollectionViewCellViewModel> {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var logoXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoYConstraint: NSLayoutConstraint!
    
    override func dataWillLoad() {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setPoster(image)
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setLogo(image)
                }
            }
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
        dataWillLoad()
    }
    
    override func viewWillConfigure() {
        posterImageView.cornerRadius(4.0)
        setTitle(viewModel.title)
        logoWillAlign()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        logoYConstraint.constant = .zero
        logoXConstraint.constant = .zero
        titleLabel.text = nil
        posterImageView.image = nil
        logoImageView.image = nil
        
        removeFromSuperview()
    }
    
    /// Align the logo constraint based on `resources.presentedLogoHorizontalAlignment`
    /// property of the media object.
    /// - Parameters:
    ///   - constraint: The value of the leading constraint.
    ///   - viewModel: Coordinating view model.
    func logoWillAlign() {
        let initial: CGFloat = 4.0
        let minX = initial
        let minY = initial
        let midX = posterImageView.bounds.maxX - logoImageView.bounds.width - (logoImageView.bounds.width / 2)
        let midY = posterImageView.bounds.maxY - logoImageView.bounds.height - (logoImageView.bounds.height / 2)
        let maxX = posterImageView.bounds.maxX - logoImageView.bounds.width - initial
        let maxY = posterImageView.bounds.maxY - logoImageView.bounds.height
        
        switch viewModel.presentedSearchLogoAlignment {
        case .minXminY:
            logoXConstraint.constant = minX
            logoYConstraint.constant = minY
        case .minXmidY:
            logoXConstraint.constant = minX
            logoYConstraint.constant = midY
        case .minXmaxY:
            logoXConstraint.constant = minX
            logoYConstraint.constant = maxY
        case .midXminY:
            logoXConstraint.constant = midX
            logoYConstraint.constant = minY
        case .midXmidY:
            logoXConstraint.constant = midX
            logoYConstraint.constant = midY
        case .midXmaxY:
            logoXConstraint.constant = midX
            logoYConstraint.constant = maxY
        case .maxXminY:
            logoXConstraint.constant = maxX
            logoYConstraint.constant = minY
        case .maxXmidY:
            logoXConstraint.constant = maxX
            logoYConstraint.constant = midY
        case .maxXmaxY:
            logoXConstraint.constant = maxX
            logoYConstraint.constant = maxY
        }
    }
}

// MARK: - ViewProtocol Implementation

extension SearchCollectionViewCell: ViewProtocol {
    fileprivate func setPoster(_ image: UIImage) {
        posterImageView.image = image
    }
    
    fileprivate func setLogo(_ image: UIImage) {
        logoImageView.image = image
    }
    
    fileprivate func setTitle(_ string: String) {
        titleLabel.text = string
    }
}
