//
//  NewsCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 27/02/2023.
//

import UIKit

// MARK: - NewsCollectionViewCell Type

final class NewsCollectionViewCell: CollectionViewCell<NewsCollectionViewCellViewModel> {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var ageRestrictionView: AgeRestrictionView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var volumeControlButton: UIButton!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var remindMeButton: UIButton!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var etaTillOnAir: UILabel!
    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var mediaTypeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var genresLabel: UILabel!
    
    // MARK: ViewLifecycleBehavior Implementation
    
    override func dataWillLoad() {
        guard representedIdentifier == viewModel.media.slug as NSString? else { return }
        
        if #available(iOS 13.0, *) {
            loadUsingAsyncAwait()
            
            return
        }
        
        loadUsingDispatchGroup()
    }
    
    override func dataDidLoad() {
        guard let previewPosterImage = imageService.object(for: viewModel.previewPosterImageIdentifier),
              let logoImage = imageService.object(for: viewModel.displayLogoImageIdentifier)
        else { return }
        
        setPoster(previewPosterImage)
        setLogo(logoImage)
    }
    
    override func viewDidLoad() {
        viewWillConfigure()
        dataWillLoad()
    }
    
    override func viewWillConfigure() {
        posterImageView.cornerRadius(10.0)
        
        setBackgroundColor(.black)
        
        setEstimatedTimeTillAir(viewModel.eta)
        setMediaType(viewModel.mediaType)
        setTitle(viewModel.media.title)
        setDescription(viewModel.media.description)
        setGenres(viewModel.media.attributedString(for: .news))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.image = nil
        logoImageView.image = nil
        
        etaTillOnAir.text = nil
        mediaTypeLabel.text = nil
        titleLabel.text = nil
        descriptionTextView.text = nil
        genresLabel.text = nil
    }
    
    // MARK: ViewProtocol Implementation
    
    override func setPoster(_ image: UIImage) {
        posterImageView.image = image
    }
    
    override func setLogo(_ image: UIImage) {
        logoImageView.image = image
    }
    
    override func setEstimatedTimeTillAir(_ text: String) {
        etaTillOnAir.text = text
    }
    
    override func setMediaType(_ text: String) {
        mediaTypeLabel.text = text
    }
    
    override func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    override func setDescription(_ text: String) {
        descriptionTextView.text = text
    }
    
    override func setGenres(_ attributedString: NSMutableAttributedString) {
        genresLabel.attributedText = attributedString
    }
    
    // MARK: CollectionViewCellResourcing Implementation
    
    override func loadUsingDispatchGroup() {
        let group = DispatchGroup()
        
        group.enter()
        posterWillLoad {
            group.leave()
        }
        
        group.enter()
        logoWillLoad {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.dataDidLoad()
        }
    }
    
    override func loadUsingAsyncAwait() {
        Task {
            await posterWillLoad()
            await logoWillLoad()
            
            dataDidLoad()
        }
    }
}

// MARK: - Private Implementation

extension NewsCollectionViewCell {
    private func posterWillLoad(_ completion: @escaping () -> Void) {
        imageService.load(
            url: viewModel.previewPosterImageURL,
            identifier: viewModel.previewPosterImageIdentifier) { _ in
                completion()
            }
    }
    
    private func logoWillLoad(_ completion: @escaping () -> Void) {
        imageService.load(
            url: viewModel.displayLogoImageURL,
            identifier: viewModel.displayLogoImageIdentifier) { _ in
                completion()
            }
    }
    
    private func posterWillLoad() async {
        guard let url = viewModel.previewPosterImageURL else { return }
        
        let identifier = viewModel.previewPosterImageIdentifier
        
        await imageService.load(url: url, identifier: identifier as String)
    }
    
    private func logoWillLoad() async {
        guard let url = viewModel.displayLogoImageURL else { return }
        
        let identifier = viewModel.displayLogoImageIdentifier
        
        await imageService.load(url: url, identifier: identifier as String)
    }
}
