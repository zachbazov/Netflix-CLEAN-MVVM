//
//  NewsTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit

final class NewsTableViewCell: UITableViewCell {
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
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    
    private var viewModel: NewsTableViewCellViewModel!
    
    static func create(in tableView: UITableView, for indexPath: IndexPath, with viewModel: NewsViewModel) -> NewsTableViewCell {
        guard let view = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell else { fatalError() }
        let cellViewModel = viewModel.items.value[indexPath.row]
        view.viewModel = NewsTableViewCellViewModel(media: cellViewModel.media)
        view.viewDidConfigure(with: view.viewModel)
        return view
    }
    
    private func viewDidConfigure(with viewModel: NewsTableViewCellViewModel) {
        let path = viewModel.media.resources.previewPoster
        let url = URL(string: path)!
        let identifier = "preview-poster_\(viewModel.media.slug)" as NSString
        
        AsyncImageFetcher.shared.load(in: .news, url: url, identifier: identifier) { [weak self] image in
            asynchrony { self?.previewPosterImageView.image = image }
        }
    }
}
