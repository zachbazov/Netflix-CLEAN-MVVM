//
//  SearchCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - SearchCollectionViewCell Type

final class SearchCollectionViewCell: CollectionViewCell<SearchCollectionViewCellViewModel> {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var logoXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoYConstraint: NSLayoutConstraint!
    
    // MARK: ViewLifecycleBehavior Implementation
    
    override func dataWillLoad() {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        if #available(iOS 13.0, *) {
            loadUsingAsyncAwait()
            
            return
        }
        
        loadUsingDispatchGroup()
    }
    
    override func dataDidLoad() {
        guard let posterImage = imageService.object(for: viewModel.posterImageIdentifier),
              let logoImage = imageService.object(for: viewModel.logoImageIdentifier)
        else { return }
        
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.setPoster(posterImage)
            self.setLogo(logoImage)
        }
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
        dataWillLoad()
    }
    
    override func viewWillConfigure() {
        posterImageView.cornerRadius(4.0)
        setTitle(viewModel.title)
        setLogoAlignment()
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
    
    // MARK: CollectionViewCellResourcing Implementation
    
    override func loadUsingAsyncAwait() {
        Task {
            await posterWillLoad()
            await logoWillLoad()
            
            dataDidLoad()
        }
    }
    
    override func loadUsingDispatchGroup() {
        let group = DispatchGroup()
        
        group.enter()
        posterWillLoad { group.leave() }
        
        group.enter()
        logoWillLoad { group.leave() }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.dataDidLoad()
        }
    }
    
    // MARK: ViewProtocol Implementation
    
    override func setLogoAlignment() {
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
    
    override func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    override func setPoster(_ image: UIImage) {
        posterImageView.image = image
    }
    
    override func setLogo(_ image: UIImage) {
        logoImageView.image = image
    }
}

// MARK: Private Implementation

extension SearchCollectionViewCell {
    private func posterWillLoad(_ completion: @escaping () -> Void) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                completion()
            }
    }
    
    private func logoWillLoad(_ completion: @escaping () -> Void) {
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { _ in
                completion()
            }
    }
    
    private func posterWillLoad() async {
        let url = viewModel.posterImageURL
        let identifier = viewModel.posterImageIdentifier as String
        
        await AsyncImageService.shared.load(url: url, identifier: identifier)
    }
    
    private func logoWillLoad() async {
        let url = viewModel.logoImageURL
        let identifier = viewModel.logoImageIdentifier as String
        
        await AsyncImageService.shared.load(url: url, identifier: identifier)
    }
}
