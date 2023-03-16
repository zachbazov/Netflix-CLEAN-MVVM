//
//  PreviewView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func createMediaPlayer(on parent: UIView,
                           view: PreviewView,
                           with viewModel: DetailViewModel) -> MediaPlayerView
}

private protocol ViewOutput {
    var mediaPlayerView: MediaPlayerView! { get }
    var imageView: UIImageView { get }
    
    func createImageView() -> UIImageView
}

private typealias ViewProtocol = ViewOutput

// MARK: - PreviewView Type

final class PreviewView: View<PreviewViewViewModel> {
    private(set) var mediaPlayerView: MediaPlayerView!
    private(set) lazy var imageView = createImageView()
    /// Create a preview view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.viewModel = .init(with: viewModel.media)
        self.viewDidConfigure()
        self.mediaPlayerView = createMediaPlayer(on: parent, view: self, with: viewModel)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        mediaPlayerView = nil
        viewModel = nil
        mediaPlayerView = nil
    }
    
    override func viewDidConfigure() {
        AsyncImageService.shared.load(
            url: viewModel.url,
            identifier: viewModel.identifier) { [weak self] image in
                mainQueueDispatch { self?.imageView.image = image }
            }
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
    
    fileprivate func createMediaPlayer(on parent: UIView,
                                       view: PreviewView,
                                       with viewModel: DetailViewModel) -> MediaPlayerView {
        let mediaPlayerView = MediaPlayerView(on: view, with: viewModel)
        
        mediaPlayerView.prepareToPlay = { [weak self] isPlaying in
            isPlaying ? self?.imageView.isHidden(true) : self?.imageView.isHidden(false)
        }
        
        mediaPlayerView.delegate?.player(mediaPlayerView.mediaPlayer,
                                         willReplaceItem: mediaPlayerView.viewModel.item)
        mediaPlayerView.delegate?.playerDidPlay(mediaPlayerView.mediaPlayer)
        
        parent.addSubview(mediaPlayerView)
        mediaPlayerView.constraintToSuperview(parent)
        
        return mediaPlayerView
    }
}
