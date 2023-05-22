//
//  AccountMenuNotificationCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - AccountMenuNotificationCollectionViewCell Type

final class AccountMenuNotificationCollectionViewCell: CollectionViewCell<AccountMenuNotificationCollectionViewCellViewModel> {
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var subjectLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var logoXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var notificationIndicator: UIView!
    
    override func viewDidLoad() {
        viewWillConfigure()
    }
    
    override func viewWillConfigure() {
        setBackgroundColor(.hexColor("#121212"))
        previewImageView.cornerRadius(4.0)
        notificationIndicator.cornerRadius(notificationIndicator.bounds.height / 2)
        
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        subjectLabel.text = viewModel.title
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                mainQueueDispatch {
                    self?.previewImageView.image = image
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                mainQueueDispatch {
                    self?.logoImageView.image = image
                }
            }
        
        logoWillAlign()
    }
    
    /// Align the logo constraint based on `resources.presentedLogoHorizontalAlignment`
    /// property of the media object.
    /// - Parameters:
    ///   - constraint: The value of the leading constraint.
    ///   - viewModel: Coordinating view model.
    fileprivate func logoWillAlign() {
        let initial: CGFloat = 4.0
        let minX = initial
        let minY = initial
        let midX = previewImageView.bounds.maxX - logoImageView.bounds.width - (logoImageView.bounds.width / 2)
        let midY = previewImageView.bounds.maxY - logoImageView.bounds.height - (logoImageView.bounds.height / 2)
        let maxX = previewImageView.bounds.maxX - logoImageView.bounds.width - initial
        let maxY = previewImageView.bounds.maxY - logoImageView.bounds.height
        
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
