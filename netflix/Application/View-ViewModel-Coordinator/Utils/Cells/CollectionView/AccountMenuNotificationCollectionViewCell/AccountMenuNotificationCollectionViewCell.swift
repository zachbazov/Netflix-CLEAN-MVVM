//
//  AccountMenuNotificationCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import UIKit

// MARK: - AccountMenuNotificationCollectionViewCell Type

final class AccountMenuNotificationCollectionViewCell: UICollectionViewCell, CollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var subjectLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var logoXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var notificationIndicator: UIView!
    
    var viewModel: AccountMenuNotificationCollectionViewCellViewModel!
    
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    var imageService: AsyncImageService = AsyncImageService.shared
    
    // MARK: DataLoadable Implementation
    
    func dataWillLoad() {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        if #available(iOS 13.0, *) {
            loadUsingAsyncAwait()
            
            return
        }
        
        loadUsingDispatchGroup()
    }
    
    func dataDidLoad() {
        guard let posterImage = imageService.object(for: viewModel.posterImageIdentifier),
              let logoImage = imageService.object(for: viewModel.logoImageIdentifier)
        else { return }
        
        mainQueueDispatch { [weak self] in
            guard let self = self else { return }
            
            self.setPoster(posterImage)
            self.setLogo(logoImage)
        }
    }
    
    // MARK: ViewLifecycleBehavior Implementation
    
    func viewDidLoad() {
        viewWillConfigure()
        dataWillLoad()
    }
    
    func viewWillConfigure() {
        notificationIndicator.cornerRadius(notificationIndicator.bounds.height / 2)
        posterImageView.cornerRadius(4.0)
        
        setBackgroundColor(.hexColor("#121212"))
        setSubject(viewModel.title)
        setLogoAlignment()
    }
    
    // MARK: CollectionViewCellResourcing Implementation
    
    func loadUsingAsyncAwait() {
        Task {
            await posterWillLoad()
            await logoWillLoad()
            
            dataDidLoad()
        }
    }
    
    func loadUsingDispatchGroup() {
        let group = DispatchGroup()
        
        group.enter()
        posterWillLoad { group.leave() }
        
        group.enter()
        logoWillLoad { group.leave() }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.dataDidLoad()
        }
    }
    
    // MARK: ViewProtocol Implementation
    
    func setSubject(_ text: String) {
        subjectLabel.text = text
    }
    
    func setPoster(_ image: UIImage) {
        posterImageView.image = image
    }
    
    func setLogo(_ image: UIImage) {
        logoImageView.image = image
    }
    
    func setLogoAlignment() {
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

// MARK: - Private Implementation

extension AccountMenuNotificationCollectionViewCell {
    private func posterWillLoad(_ completion: @escaping () -> Void) {
        imageService.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { _ in
                completion()
            }
    }
    
    private func logoWillLoad(_ completion: @escaping () -> Void) {
        imageService.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { _ in
                completion()
            }
    }
    
    private func posterWillLoad() async {
        let url = viewModel.posterImageURL
        let identifier = viewModel.posterImageIdentifier as String
        
        await imageService.load(url: url, identifier: identifier)
    }
    
    private func logoWillLoad() async {
        let url = viewModel.logoImageURL
        let identifier = viewModel.logoImageIdentifier as String
        
        await imageService.load(url: url, identifier: identifier)
    }
}
