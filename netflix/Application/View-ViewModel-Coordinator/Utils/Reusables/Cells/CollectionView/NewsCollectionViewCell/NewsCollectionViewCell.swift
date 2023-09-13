//
//  NewsCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 27/02/2023.
//

import UIKit

// MARK: - NewsCollectionViewCell Type

final class NewsCollectionViewCell: UICollectionViewCell, CollectionViewCell {
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
    
    var viewModel: NewsCollectionViewCellViewModel!
    
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    // MARK: DataLoadable Implementation
    
    func dataDidLoad() {
        let imageService = Application.app.services.image
        
        guard let previewPosterImage = imageService.cache.object(for: viewModel.previewPosterImageIdentifier),
              let logoImage = imageService.cache.object(for: viewModel.displayLogoImageIdentifier)
        else { return }
        
        setPoster(previewPosterImage)
        setLogo(logoImage)
    }
    
    // MARK: ViewLifecycleBehavior Implementation
    
    func viewDidLoad() {
        viewWillConfigure()
        
        fetchData()
    }
    
    func viewWillConfigure() {
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
    
    func setPoster(_ image: UIImage) {
        posterImageView.image = image
    }
    
    func setLogo(_ image: UIImage) {
        logoImageView.image = image
    }
    
    func setEstimatedTimeTillAir(_ text: String) {
        etaTillOnAir.text = text
    }
    
    func setMediaType(_ text: String) {
        mediaTypeLabel.text = text
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    func setDescription(_ text: String) {
        descriptionTextView.text = text
    }
    
    func setGenres(_ attributedString: NSMutableAttributedString) {
        genresLabel.attributedText = attributedString
    }
    
    // MARK: CollectionViewCellResourcing Implementation
    
    func fetchData() {
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
}

// MARK: - Private Implementation

extension NewsCollectionViewCell {
    private func posterWillLoad(_ completion: @escaping () -> Void) {
        let imageService = Application.app.services.image
        
        imageService.load(
            url: viewModel.previewPosterImageURL,
            identifier: viewModel.previewPosterImageIdentifier) { [weak self] _ in
            guard let self = self, self.representedIdentifier == self.viewModel.media.slug as NSString? else { return }
            
            completion()
        }
    }
    
    private func logoWillLoad(_ completion: @escaping () -> Void) {
        let imageService = Application.app.services.image
        
        imageService.load(
            url: viewModel.displayLogoImageURL,
            identifier: viewModel.displayLogoImageIdentifier) { [weak self] _ in
            guard let self = self, self.representedIdentifier == self.viewModel.media.slug as NSString? else { return }
            
            completion()
        }
    }
}
