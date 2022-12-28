//
//  DisplayView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

struct DisplayViewConfiguration {
    private weak var view: DisplayView?
    /// Create a configuration object for the display view.
    /// - Parameters:
    ///   - view: The view itself.
    ///   - viewModel: Coordinating view model.
    init(view: DisplayView, viewModel: DisplayViewViewModel) {
        self.view = view
        self.viewDidConfigure(with: viewModel)
    }
    /// Configure the view.
    /// - Parameter viewModel: Coordinating view model.
    func viewDidConfigure(with viewModel: DisplayViewViewModel) {
        view?.posterImageView.image = nil
        view?.logoImageView.image = nil
        view?.genresLabel.attributedText = nil
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { image in
                asynchrony { view?.posterImageView.image = image }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { image in
                asynchrony { view?.logoImageView.image = image }
            }
        
        view?.genresLabel.attributedText = viewModel.attributedGenres
    }
}

final class DisplayView: UIView, ViewInstantiable {
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    var viewModel: DisplayViewViewModel!
    private(set) var configuration: DisplayViewConfiguration!
    private(set) var panelView: PanelView!
    /// Create a display view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: DisplayTableViewCellViewModel) {
        super.init(frame: .zero)
        self.nibDidLoad()
        let homeViewModel = viewModel.coordinator!.viewController!.viewModel!
        let mediaFromCache = mediaFromCache(with: homeViewModel)
        self.viewModel = DisplayViewViewModel(with: mediaFromCache)
        self.panelView = PanelView(on: panelViewContainer, with: viewModel)
        self.configuration = DisplayViewConfiguration(view: self, viewModel: self.viewModel)
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    private func viewDidLoad() {
        setupSubviews()
    }
    
    private func setupSubviews() {
        setupGradientView()
    }
    
    private func setupGradientView() {
        bottomGradientView.addGradientLayer(
            frame: bottomGradientView.bounds,
            colors: [.clear, .black],
            locations: [0.0, 0.66])
        
        posterImageView.contentMode = .scaleAspectFill
    }
}

extension DisplayView {
    /// Retrieve a media object from the display cache.
    /// - Parameter viewModel: Coordinating view model.
    /// - Returns: A media object.
    func mediaFromCache(with viewModel: HomeViewModel) -> Media {
        if case .all = viewModel.dataSourceState.value { return viewModel.displayMediaCache[.all]! }
        else if case .series = viewModel.dataSourceState.value { return viewModel.displayMediaCache[.series]! }
        else { return viewModel.displayMediaCache[.films]! }
    }
}
