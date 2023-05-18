//
//  CollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - CollectionViewCell Type

class CollectionViewCell: HomeCollectionCell<CollectionViewCellViewModel> {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var logoBottomConstraint: NSLayoutConstraint!
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.image = nil
        logoImageView.image = nil
        placeholderLabel.text = nil
        logoBottomConstraint?.constant = .zero
        representedIdentifier = nil
        viewModel = nil
    }
    
    // MARK: ViewProtocol Overridable
    
    /// Asynchronous download/load object resources.
    /// - Parameters:
    ///   - viewModel: Coordinating view model.
    ///   - completion: Completion handler.
    func dataWillDownload(with viewModel: CollectionViewCellViewModel,
                          completion: (() -> Void)?) {
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                mainQueueDispatch { completion?() }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { _ in
                mainQueueDispatch { completion?() }
            }
    }
    
    /// View's initials setup.
    /// - Parameters:
    ///   - media: Corresponding media object.
    ///   - viewModel: Coordinating view model.
    func viewDidLoad(media: Media, with viewModel: CollectionViewCellViewModel) {
        setBackgroundColor(.clear)
        
        placeholderLabel.alpha = 1.0
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 4.0
        posterImageView.contentMode = .scaleAspectFill
        
        dataWillDownload(with: viewModel) { [weak self] in
            self?.viewWillConfigure(with: viewModel)
        }
        
        representedIdentifier = media.slug as NSString
        placeholderLabel.text = viewModel.title
    }
    
    /// Overridable configuration operation.
    /// Configure the view based on the view model.
    /// - Parameter viewModel: Coordinating view model.
    func viewWillConfigure(with viewModel: CollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        let posterImage = AsyncImageService.shared.object(for: viewModel.posterImageIdentifier)
        let logoImage = AsyncImageService.shared.object(for: viewModel.logoImageIdentifier)
        posterImageView.image = posterImage
        logoImageView.image = logoImage

        placeholderLabel.alpha = 0.0
        
        guard let logoBottomConstraint = logoBottomConstraint else { return }
        logoWillAlign(logoBottomConstraint, with: viewModel)
    }
    
    /// Align the logo constraint based on `resources.presentedLogoAlignment`
    /// property of the media object.
    /// - Parameters:
    ///   - constraint: The value of the bottom constraint.
    ///   - viewModel: Coordinating view model.
    func logoWillAlign(_ constraint: NSLayoutConstraint, with viewModel: CollectionViewCellViewModel) {
        switch viewModel.presentedLogoAlignment {
        case .top: constraint.constant = bounds.maxY - logoImageView.bounds.height - 8.0
        case .midTop: constraint.constant = 64.0
        case .mid: constraint.constant = bounds.midY
        case .midBottom: constraint.constant = 24.0
        case .bottom: constraint.constant = 8.0
        }
    }
    
    // MARK: ViewLifecycleBehavior Overridable
    
    func viewDidLoad() {}
    func viewWillDeploySubviews() {}
    func viewDidDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewHierarchyDidConfigure() {}
    func viewWillConfigure() {}
    func viewDidConfigure() {}
    
    func viewWillDeallocate() {
        representedIdentifier = nil
        
        viewModel = nil
        
        removeFromSuperview()
    }
    func viewDidDeallocate() {}
}
