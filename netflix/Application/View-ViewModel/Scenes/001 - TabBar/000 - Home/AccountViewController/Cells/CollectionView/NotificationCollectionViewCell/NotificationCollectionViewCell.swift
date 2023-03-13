//
//  NotificationCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

final class NotificationCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var subjectLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var logoXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var notificationIndicator: UIView!
    
    var representedIdentifier: NSString?
    
    static func create(in collectionView: UICollectionView,
                       at indexPath: IndexPath,
                       with viewModel: AccountViewModel) -> NotificationCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: NotificationCollectionViewCell.reuseIdentifier,
            for: indexPath) as? NotificationCollectionViewCell else { fatalError() }
        guard let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as? HomeViewController else { fatalError() }
        let myList = homeViewController.viewModel.myList.viewModel.list.value.toArray()
        let model = myList[indexPath.row]
        let cellViewModel = SearchCollectionViewCellViewModel(media: model)
        view.representedIdentifier = cellViewModel.slug as NSString
        view.viewDidConfigure()
        view.viewDidConfigure(with: cellViewModel)
        return view
    }
    
    func viewDidConfigure() {
        backgroundColor = .hexColor("#121212")
        
        previewImageView.layer.cornerRadius = 4.0
        notificationIndicator.layer.cornerRadius = notificationIndicator.bounds.height / 2
    }
    
    func viewDidConfigure(with viewModel: SearchCollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        subjectLabel.text = viewModel.title
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard self?.representedIdentifier == viewModel.slug as NSString? else { return }
                mainQueueDispatch {
                    self?.previewImageView.image = image
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

extension NotificationCollectionViewCell: ViewLifecycleBehavior {}
