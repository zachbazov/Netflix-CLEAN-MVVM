//
//  OpaqueView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var imageView: UIImageView! { get }
    var blurView: UIVisualEffectView! { get }
    
    func viewDidUpdate()
}

// MARK: - OpaqueView Type

final class OpaqueView: View<OpaqueViewViewModel> {
    fileprivate var imageView: UIImageView!
    fileprivate var blurView: UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidConfigure() {
        guard let viewModel = viewModel else { return }
        
        imageView?.removeFromSuperview()
        blurView?.removeFromSuperview()
        
        imageView = .init(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = .init(effect: blurEffect)
        blurView.frame = imageView.bounds
        
//        insertSubview(imageView, at: 0)
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
    func viewDidUpdate() {
        guard let homeVC = Application.app.coordinator.tabCoordinator.home.viewControllers.first as? HomeViewController,
              let media = homeVC.viewModel.showcases[HomeTableViewDataSource.State(rawValue: homeVC.viewModel.dataSourceState.value?.rawValue ?? 0) ?? .all]
        else { return }
        
        viewModel = OpaqueViewViewModel(with: media)
        
        viewDidConfigure()
    }
}
