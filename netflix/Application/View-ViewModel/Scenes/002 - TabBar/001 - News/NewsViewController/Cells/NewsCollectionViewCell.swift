//
//  NewsCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 27/02/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var representedIdentifier: String? { get }
    
    func viewDidConfigure(with viewModel: NewsCollectionViewCellViewModel)
}

private typealias ViewProtocol = ViewOutput

// MARK: - NewsCollectionViewCell Type

final class NewsCollectionViewCell: UICollectionViewCell {
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
    
    fileprivate var viewModel: NewsCollectionViewCellViewModel!
    fileprivate var representedIdentifier: String?
    
    static func create(in collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with viewModel: NewsViewModel) -> NewsCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: NewsCollectionViewCell.reuseIdentifier,
            for: indexPath) as? NewsCollectionViewCell else {
            fatalError()
        }
        let cellViewModel = viewModel.items.value[indexPath.row]
        view.representedIdentifier = cellViewModel.media.slug
        view.viewModel = NewsCollectionViewCellViewModel(with: cellViewModel.media)
        view.viewDidConfigure()
        view.viewDidConfigure(with: view.viewModel)
        return view
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension NewsCollectionViewCell: ViewLifecycleBehavior {
    func viewDidConfigure() {
        backgroundColor = .black
        previewPosterImageView.layer.cornerRadius = 10.0
    }
}

// MARK: - ViewProtocol Implementation

extension NewsCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: NewsCollectionViewCellViewModel) {
        AsyncImageService.shared.load(
            url: viewModel.previewPosterImageURL,
            identifier: viewModel.previewPosterImageIdentifier) { [weak self] image in
                guard self!.representedIdentifier == viewModel.media.slug else { return }
                mainQueueDispatch {
                    self?.previewPosterImageView.image = image
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.displayLogoImageURL,
            identifier: viewModel.displayLogoImageIdentifier) { [weak self] image in
                guard self!.representedIdentifier == viewModel.media.slug else { return }
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
