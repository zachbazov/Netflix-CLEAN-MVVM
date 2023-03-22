//
//  ShowcaseView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var panelView: PanelView! { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - ShowcaseView Type

final class ShowcaseView: View<ShowcaseViewViewModel> {
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    private(set) var panelView: PanelView!
    
    /// Create a display view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: ShowcaseTableViewCellViewModel) {
        super.init(frame: .zero)
        self.nibDidLoad()
        let homeViewModel = viewModel.coordinator!.viewController!.viewModel!
        let media = homeViewModel.showcases[homeViewModel.dataSourceState.value ?? .all]
        self.viewModel = ShowcaseViewViewModel(with: media)
        self.panelView = PanelView(on: panelViewContainer, with: viewModel)
        self.viewDidDeploySubviews()
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        panelView.viewDidUnbindObservers()
        panelView.removeFromSuperview()
        panelView = nil
    }
    
    override func viewDidDeploySubviews() {
        setupGradients()
        setupImageContent()
    }
    
    override func viewDidConfigure() {
        posterImageView.image = nil
        logoImageView.image = nil
        genresLabel.attributedText = nil
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                mainQueueDispatch { self?.posterImageView.image = image }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                mainQueueDispatch { self?.logoImageView.image = image }
            }
        
        genresLabel.attributedText = viewModel.attributedGenres
    }
}

// MARK: - ViewInstantiable Implementation

extension ShowcaseView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension ShowcaseView: ViewProtocol {}

// MARK: - Private UI Implementation

extension ShowcaseView {
    func setupGradients() {
        bottomGradientView.addGradientLayer(colors: [.clear, .black], locations: [0.0, 0.66])
    }
    
    private func setupImageContent() {
        posterImageView.contentMode = .scaleAspectFill
    }
}
