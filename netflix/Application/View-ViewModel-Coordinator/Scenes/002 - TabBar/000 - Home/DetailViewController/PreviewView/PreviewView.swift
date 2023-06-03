//
//  PreviewView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var mediaPlayerView: MediaPlayerView? { get }
    var imageView: UIImageView { get }
    
    func createImageView() -> UIImageView
    func createMediaPlayer()
    
    func viewWillPrepareForPlaying(_ played: Bool)
    func setImage(_ image: UIImage)
    
    func loadResources()
}

// MARK: - PreviewView Type

final class PreviewView: UIView, View {
    private(set) var mediaPlayerView: MediaPlayerView?
    private(set) lazy var imageView = createImageView()
    
    var viewModel: PreviewViewViewModel!
    
    /// Create a preview view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        
        self.viewModel = PreviewViewViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewWillDeallocate()
    }
    
    func dataWillLoad() {
        loadResources()
    }
    
    func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillDeploySubviews()
        viewWillConfigure()
        dataWillLoad()
    }
    
    func viewHierarchyWillConfigure() {
        guard let container = viewModel.coordinator.viewController?.previewContainer else { return }
        
        self.addToHierarchy(on: container)
            .constraintToSuperview(container)
    }
    
    func viewWillDeploySubviews() {
        createMediaPlayer()
    }
    
    func viewWillConfigure() {
        configureMediaPlayer()
    }
    
    func viewWillDeallocate() {
        mediaPlayerView = nil
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension PreviewView: ViewProtocol {
    fileprivate func createImageView() -> UIImageView {
        let imageView = UIImageView(frame: bounds)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        return imageView
    }
    
    fileprivate func createMediaPlayer() {
        guard let viewModel = viewModel.coordinator.viewController?.viewModel else { return }
        
        mediaPlayerView = MediaPlayerView(with: viewModel)
    }
    
    fileprivate func viewWillPrepareForPlaying(_ played: Bool) {
        mainQueueDispatch(delayInSeconds: 1) { [ weak self] in
            guard let self = self else { return }
            
            self.imageView.isHidden(played ? true : false)
        }
    }
    
    fileprivate func loadResources() {
        AsyncImageService.shared.load(
            url: viewModel.url,
            identifier: viewModel.identifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setImage(image)
                }
            }
    }
    
    fileprivate func setImage(_ image: UIImage) {
        imageView.image = image
    }
}

// MARK: - Private Implementation

extension PreviewView {
    private func configureMediaPlayer() {
        guard let mediaPlayer = mediaPlayerView?.mediaPlayer else { fatalError() }
        
        mediaPlayerView?.prepareToPlay = { [weak self] isPlaying in
            self?.viewWillPrepareForPlaying(isPlaying)
        }
        
        mediaPlayerView?
            .delegate?
            .player(mediaPlayer, willReplaceItem: mediaPlayerView?.viewModel.item)
        
        mediaPlayerView?
            .delegate?
            .playerDidPlay(mediaPlayer)
    }
}
