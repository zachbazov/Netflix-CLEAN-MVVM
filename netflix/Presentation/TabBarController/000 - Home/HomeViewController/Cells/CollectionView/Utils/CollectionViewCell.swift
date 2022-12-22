//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var logoBottomConstraint: NSLayoutConstraint!
    
    private var viewModel: CollectionViewCellViewModel!
    private var representedIdentifier: NSString?
    /// Create a collection view cell object.
    /// - Parameters:
    ///   - collectionView: The referenced collection view.
    ///   - reuseIdentifier: Cell's reuse identifier.
    ///   - section: The section the cell represents.
    ///   - indexPath: The index path of the cell on the collection view.
    /// - Returns: A collection cell object.
    static func create(on collectionView: UICollectionView,
                       reuseIdentifier: String,
                       section: Section,
                       for indexPath: IndexPath) -> CollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
            fatalError()
        }
        let media = section.media[indexPath.row]
        let cellViewModel = CollectionViewCellViewModel(media: media, indexPath: indexPath)
        view.viewModel = cellViewModel
        view.viewDidLoad(media: media, with: cellViewModel)
        return view
    }
    
    deinit {
        representedIdentifier = nil
        viewModel = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        coverImageView.image = nil
        logoImageView.image = nil
        placeholderLabel.text = nil
        representedIdentifier = nil
    }
    /// Overridable configuration operation.
    /// Configure the view based on the view model.
    /// - Parameter viewModel: Coordinating view model.
    public func viewDidConfigure(with viewModel: CollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        let posterImage = AsyncImageFetcher.shared.object(in: .home, for: viewModel.posterImageIdentifier)
        let logoImage = AsyncImageFetcher.shared.object(in: .home, for: viewModel.logoImageIdentifier)
        coverImageView.image = posterImage
        logoImageView.image = logoImage

        placeholderLabel.alpha = 0.0
        
        logoDidAlign(logoBottomConstraint, with: viewModel)
    }
}

extension CollectionViewCell {
    /// Asynchronous download/load object resources.
    /// - Parameters:
    ///   - viewModel: Coordinating view model.
    ///   - completion: Completion handler.
    private func dataDidDownload(with viewModel: CollectionViewCellViewModel,
                                 completion: (() -> Void)?) {
        AsyncImageFetcher.shared.load(
            in: .home,
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                asynchrony { completion?() }
            }
        AsyncImageFetcher.shared.load(
            in: .home,
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { _ in
                asynchrony { completion?() }
            }
    }
    /// View's initials setup.
    /// - Parameters:
    ///   - media: Corresponding media object.
    ///   - viewModel: Coordinating view model.
    private func viewDidLoad(media: Media, with viewModel: CollectionViewCellViewModel) {
        backgroundColor = .black
        
        placeholderLabel.alpha = 1.0
        coverImageView.layer.cornerRadius = 6.0
        coverImageView.contentMode = .scaleAspectFill
        
        dataDidDownload(with: viewModel) { [weak self] in
            self?.viewDidConfigure(with: viewModel)
        }
        
        representedIdentifier = media.slug as NSString
        placeholderLabel.text = viewModel.title
    }
    /// Align the logo constraint based on `resources.presentedLogoAlignment`
    /// property of the media object.
    /// - Parameters:
    ///   - constraint: The value of the bottom constraint.
    ///   - viewModel: Coordinating view model.
    private func logoDidAlign(_ constraint: NSLayoutConstraint,
                              with viewModel: CollectionViewCellViewModel) {
        switch viewModel.presentedLogoAlignment {
        case .top: constraint.constant = bounds.maxY - logoImageView.bounds.height - 8.0
        case .midTop: constraint.constant = 64.0
        case .mid: constraint.constant = bounds.midY
        case .midBottom: constraint.constant = 24.0
        case .bottom: constraint.constant = 8.0
        }
    }
}
