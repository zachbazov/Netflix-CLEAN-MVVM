//
//  OpaqueView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

final class OpaqueView: UIView {
    private var imageView: UIImageView!
    private var blurView: UIVisualEffectView!
    private(set) var viewModel: OpaqueViewViewModel!
}

extension OpaqueView {
    private func viewDidConfigure() {
        imageView?.removeFromSuperview()
        blurView?.removeFromSuperview()
        
        imageView = .init(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = .init(effect: blurEffect)
        blurView.frame = imageView.bounds
        
        insertSubview(imageView, at: 0)
        insertSubview(blurView, at: 1)
        /// Download media resource.
        AsyncImageService.shared.load(
            url: viewModel.imageURL,
            identifier: viewModel.identifier) { [weak self] image in
                asynchrony { self?.imageView.image = image }
            }
    }
    /// Release changes for the view by the view model.
    /// - Parameter media: Corresponding media object.
    func viewModelDidUpdate(with media: Media) {
        /// Extract the presented media object on `DisplayView`.
        guard let presentedMedia = media as Media? else { return }
        viewModel = OpaqueViewViewModel(with: presentedMedia)
        /// Release changes.
        viewDidConfigure()
    }
}
