//
//  MediaCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - MediaCollectionViewCell Type

class MediaCollectionViewCell: UICollectionViewCell, CollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet private weak var logoBottomConstraint: NSLayoutConstraint!
    
    var viewModel: MediaCollectionViewCellViewModel!
    
    var representedIdentifier: NSString!
    var indexPath: IndexPath!
    
    var imageService: AsyncImageService = AsyncImageService.shared
    
//    deinit {
//        viewWillDeallocate()
//    }
    
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
        
        hidePlaceholder()
        
        setPoster(posterImage)
        setLogo(logoImage)
    }
    
    // MARK: ViewLifecycleBehavior Implementation
    
    func viewDidLoad() {
        viewWillConfigure()
        dataWillLoad()
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.clear)
        
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.cornerRadius(4.0)
        
        placeholderLabel.alpha = 1.0
        setPlaceholder(viewModel.title)
        
        setLogoAlignment()
    }
    
    func viewWillDeallocate() {
        representedIdentifier = nil
        indexPath = nil
        viewModel = nil
        
        posterImageView.image = nil
        logoImageView.image = nil
        placeholderLabel.text = nil
        logoBottomConstraint?.constant = .zero
        
        removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewWillDeallocate()
    }
    
    // MARK: ViewProtocol Implementation
    
    func setLogoAlignment() {
        guard let constraint = logoBottomConstraint else { return }
        
        switch viewModel.presentedLogoAlignment {
        case .top: constraint.constant = bounds.maxY - logoImageView.bounds.height - 8.0
        case .midTop: constraint.constant = 64.0
        case .mid: constraint.constant = bounds.midY
        case .midBottom: constraint.constant = 24.0
        case .bottom: constraint.constant = 8.0
        }
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
        posterWillLoad { group.leave()}
        
        group.enter()
        logoWillLoad { group.leave() }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.hidePlaceholder()
            self.dataDidLoad()
        }
    }
    
    func resourceWillLoad(for url: URL, withIdentifier identifier: NSString, _ completion: @escaping () -> Void) {
        imageService.load(url: url, identifier: identifier) { _ in
            completion()
        }
    }
    
    func resourceWillLoad(for url: URL, withIdentifier identifier: String) async {
        await imageService.load(url: url, identifier: identifier)
    }
    
    // MARK: ViewProtocol Implementation
    
    func setPoster(_ image: UIImage) {
        posterImageView.image = image
    }
    
    func setLogo(_ image: UIImage) {
        logoImageView.image = image
    }
    
    func setPlaceholder(_ text: String) {
        placeholderLabel.text = text
    }
    
    func hidePlaceholder() {
        placeholderLabel.alpha = .zero
    }
}

// MARK: - Private Implementation

extension MediaCollectionViewCell {
    private func posterWillLoad(_ completion: @escaping () -> Void) {
        resourceWillLoad(for: viewModel.posterImageURL, withIdentifier: viewModel.posterImageIdentifier, completion)
    }
    
    private func logoWillLoad(_ completion: @escaping () -> Void) {
        resourceWillLoad(for: viewModel.logoImageURL, withIdentifier: viewModel.logoImageIdentifier, completion)
    }
    
    private func posterWillLoad() async {
        guard let url = viewModel.posterImageURL else { return }
        
        let identifier = viewModel.posterImageIdentifier as String
        
        await resourceWillLoad(for: url, withIdentifier: identifier)
    }
    
    private func logoWillLoad() async {
        guard let url = viewModel.logoImageURL else { return }
        
        let identifier = viewModel.logoImageIdentifier as String
        
        await resourceWillLoad(for: url, withIdentifier: identifier)
    }
}
