//
//  SearchCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: SearchCollectionViewCellViewModel)
    func logoDidAlign(with viewModel: SearchCollectionViewCellViewModel)
}

private protocol ViewOutput {
    var representedIdentifier: NSString? { get }
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - SearchCollectionViewCell Type

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var logoXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoYConstraint: NSLayoutConstraint!
    
    fileprivate var representedIdentifier: NSString?
    /// Create a search collection view cell object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A search collection view cell.
    static func create(on collectionView: UICollectionView,
                       for indexPath: IndexPath,
                       with viewModel: SearchViewModel) -> SearchCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SearchCollectionViewCell else {
            fatalError()
        }
        let media = viewModel.items.value[indexPath.row].media!
        let cellViewModel = SearchCollectionViewCellViewModel(media: media)
        view.representedIdentifier = cellViewModel.slug as NSString
        view.viewDidConfigure()
        view.viewDidConfigure(with: cellViewModel)
        return view
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        logoImageView.image = nil
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension SearchCollectionViewCell: ViewLifecycleBehavior {
    func viewDidConfigure() {
        posterImageView.layer.cornerRadius = 4.0
    }
}

// MARK: - ViewProtocol Implementation

extension SearchCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: SearchCollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        titleLabel.text = viewModel.title
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard self?.representedIdentifier == viewModel.slug as NSString? else { return }
                mainQueueDispatch {
                    self?.posterImageView.image = image
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                guard self?.representedIdentifier == viewModel.slug as NSString? else { return }
                mainQueueDispatch {
                    self?.logoImageView.image = image
                }
            }
        
        logoDidAlign(with: viewModel)
    }
    /// Align the logo constraint based on `resources.presentedLogoHorizontalAlignment`
    /// property of the media object.
    /// - Parameters:
    ///   - constraint: The value of the leading constraint.
    ///   - viewModel: Coordinating view model.
    func logoDidAlign(with viewModel: SearchCollectionViewCellViewModel) {
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
