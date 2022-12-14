//
//  NewsTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

// MARK: - NewsTableViewCell Type

final class NewsTableViewCell: UITableViewCell {
    
    // MARK: Outlet Properties
    
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
    
    // MARK: Type's Properties
    
    private var viewModel: NewsTableViewCellViewModel!
    private var representedIdentifier: String?
    
    // MARK: Initializer
    
    /// Create a news table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A news table view cell.
    static func create(in tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: NewsViewModel) -> NewsTableViewCell {
        guard let view = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.reuseIdentifier,
            for: indexPath) as? NewsTableViewCell else {
            fatalError()
        }
        let cellViewModel = viewModel.items.value[indexPath.row]
        view.representedIdentifier = cellViewModel.media.slug
        view.viewModel = NewsTableViewCellViewModel(with: cellViewModel.media)
        view.setupSubviews()
        view.viewDidConfigure(with: view.viewModel)
        return view
    }
}

// MARK: - UI Setup

extension NewsTableViewCell {
    private func setupSubviews() {
        selectionStyle = .none
        backgroundColor = .black
        previewPosterImageView.layer.cornerRadius = 10.0
    }
    
    private func viewDidConfigure(with viewModel: NewsTableViewCellViewModel) {
        guard representedIdentifier == viewModel.media.slug else { return }
        
        AsyncImageService.shared.load(
            url: viewModel.previewPosterImageURL,
            identifier: viewModel.previewPosterImageIdentifier) { [weak self] image in
                asynchrony { self?.previewPosterImageView.image = image }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.displayLogoImageURL,
            identifier: viewModel.displayLogoImageIdentifier) { [weak self] image in
                asynchrony { self?.logoImageView.image = image }
            }
        
        etaTillOnAir.text = viewModel.eta
        mediaTypeLabel.text = viewModel.mediaType
        titleLabel.text = viewModel.media.title
        descriptionTextView.text = viewModel.media.description
        genresLabel.attributedText = viewModel.media.attributedString(for: .news)
    }
}
