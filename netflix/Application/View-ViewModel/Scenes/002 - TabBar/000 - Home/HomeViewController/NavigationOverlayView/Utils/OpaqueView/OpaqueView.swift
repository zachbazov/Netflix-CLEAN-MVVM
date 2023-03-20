//
//  OpaqueView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidUpdate(with media: Media)
}

private protocol ViewOutput {
    var imageView: UIImageView! { get }
    var blurView: UIVisualEffectView! { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - OpaqueView Type

final class OpaqueView: View<OpaqueViewViewModel> {
    fileprivate var imageView: UIImageView!
    fileprivate var blurView: UIVisualEffectView!
    
    override func viewDidConfigure() {
        imageView?.removeFromSuperview()
        blurView?.removeFromSuperview()
        
        imageView = .init(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = .init(effect: blurEffect)
        blurView.frame = imageView.bounds
        
        insertSubview(imageView, at: 0)
        insertSubview(blurView, at: 1)
        
        AsyncImageService.shared.load(
            url: viewModel.imageURL,
            identifier: viewModel.identifier) { [weak self] image in
                mainQueueDispatch { self?.imageView.image = image }
            }
    }
}

// MARK: - ViewProtocol Implementation

extension OpaqueView: ViewProtocol {
    /// Release changes for the view by the view model.
    /// - Parameter media: Corresponding media object.
    func viewDidUpdate(with media: Media) {
        // Extract the presented media object on `DisplayView`.
        guard let presentedMedia = media as Media? else { return }
        viewModel = OpaqueViewViewModel(with: presentedMedia)
        // Release changes.
        viewDidConfigure()
    }
}