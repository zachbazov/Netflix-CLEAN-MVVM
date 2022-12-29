//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - CollectionViewCell Type

class CollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlet Properties
    
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var logoBottomConstraint: NSLayoutConstraint!
    
    // MARK: Type's Properties
    
    private var viewModel: CollectionViewCellViewModel!
    private var representedIdentifier: NSString?
    
    // MARK: Initializer
    
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
    
    // MARK: Deinitializer
    
    deinit {
        representedIdentifier = nil
        viewModel = nil
    }
    
    // MARK: UICollectionViewCell Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        logoImageView.image = nil
        placeholderLabel.text = nil
        logoBottomConstraint.constant = .zero
        representedIdentifier = nil
        viewModel = nil
    }
    
    // MARK: UI Setup
    
    /// Overridable configuration operation.
    /// Configure the view based on the view model.
    /// - Parameter viewModel: Coordinating view model.
    public func viewDidConfigure(with viewModel: CollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        let posterImage = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        let logoImage = AsyncImageService.shared.object(for: viewModel.logoImageIdentifier)
        coverImageView.image = posterImage
        logoImageView.image = logoImage

        placeholderLabel.alpha = 0.0
        
        logoDidAlign(logoBottomConstraint, with: viewModel)
    }
}

// MARK: - UI Setup

extension CollectionViewCell {
    /// Asynchronous download/load object resources.
    /// - Parameters:
    ///   - viewModel: Coordinating view model.
    ///   - completion: Completion handler.
    private func dataDidDownload(with viewModel: CollectionViewCellViewModel,
                                 completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                asynchrony { completion?() }
            }
        AsyncImageService.shared.load(
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
