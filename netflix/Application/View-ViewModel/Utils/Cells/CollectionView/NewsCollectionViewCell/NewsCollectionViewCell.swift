//
//  NewsCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 27/02/2023.
//

import UIKit

// MARK: - NewsCollectionViewCell Type

final class NewsCollectionViewCell: CollectionViewCell<NewsCollectionViewCellViewModel> {
    @IBOutlet private weak var previewPosterImageView: UIImageView!
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
    
    override func viewDidLoad() {
        viewWillConfigure()
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.black)
        previewPosterImageView.cornerRadius(10.0)
        
        guard representedIdentifier == viewModel.media.slug as NSString? else { return }
        
        AsyncImageService.shared.load(
            url: viewModel.previewPosterImageURL,
            identifier: viewModel.previewPosterImageIdentifier) { [weak self] image in
                mainQueueDispatch {
                    self?.previewPosterImageView.image = image
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.displayLogoImageURL,
            identifier: viewModel.displayLogoImageIdentifier) { [weak self] image in
                mainQueueDispatch {
                    self?.logoImageView.image = image
                }
            }
        
        etaTillOnAir.text = viewModel.eta
        mediaTypeLabel.text = viewModel.mediaType
        titleLabel.text = viewModel.media.title
        descriptionTextView.text = viewModel.media.description
        genresLabel.attributedText = viewModel.media.attributedString(for: .news)
    }
}
