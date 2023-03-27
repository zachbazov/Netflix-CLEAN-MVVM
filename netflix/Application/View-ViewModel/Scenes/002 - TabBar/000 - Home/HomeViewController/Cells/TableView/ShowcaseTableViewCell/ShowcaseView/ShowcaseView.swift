//
//  ShowcaseView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var panelView: PanelView! { get }
}

// MARK: - ShowcaseView Type

final class ShowcaseView: View<ShowcaseViewViewModel> {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView! // disposable
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
        self.contentView.constraintToSuperview(self)
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
    }
    
    override func viewDidConfigure() {
        backgroundColor = .clear
        
        let gradient = UIImage.fillGradientStroke(bounds: posterImageView.bounds,
                                                  colors: [.white.withAlphaComponent(0.5), .clear])
        let gradientColor = UIColor(patternImage: gradient)
        posterImageView.layer.borderColor = gradientColor.cgColor
        posterImageView.layer.borderWidth = 1.5
        posterImageView.layer.cornerRadius = 12.0
//        contentView.layer.shadow(.red, radius: 24.0, opacity: 1.0)
        
        posterImageView.image = nil
        logoImageView.image = nil
        genresLabel.attributedText = nil
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self else { return }
                mainQueueDispatch { self.posterImageView.image = image }
                mainQueueDispatch {
                    let colorComponents = image!.averageColor!.cgColor.components!
                    let red = colorComponents[0]
                    let green = colorComponents[1]
                    let blue = colorComponents[2]
                    let gradientView = UIView(frame: self.contentView.bounds)
                    let gradientLayer = CAGradientLayer()
                    
                    let color1 = image!.averageColor
                    let color2 = image!.areaAverage().darkerColor(for: color1!)
                    let color3 = color2.darkerColor(for: color2)
                    
                    gradientLayer.frame = gradientView.bounds
                    gradientLayer.colors = [color1!.cgColor,
                                            color2.cgColor,
                                            color3.cgColor,
                                            UIColor.black.cgColor]
                    gradientLayer.locations = [0.0, 0.3, 0.7, 1.0]
                    gradientView.layer.addSublayer(gradientLayer)
                    
                    self.contentView.insertSubview(gradientView, at: 0)
                    
                    let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as! HomeViewController
                    homeViewController.dataSource?.colors = [color1!, color2, color3]
                    
                    homeViewController.dataSource?.setupGradient(with: homeViewController)
                    
                    self.contentView.layer.shadow(color3, radius: 24.0, opacity: 1.0)
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                mainQueueDispatch { self?.logoImageView.image = image }
            }
        
        genresLabel.attributedText = viewModel.attributedGenres
        
        self.typeImageView.image = UIImage(named: viewModel.typeImagePath)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTap() {
        let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first as! HomeViewController
        let homeViewModel = homeViewController.viewModel
        guard let state = homeViewModel?.dataSourceState.value else { return }
        let coordinator = homeViewModel!.coordinator!
        let section = homeViewModel!.section(at: .resumable)
        let media = homeViewModel!.showcases[HomeTableViewDataSource.State(rawValue: state.rawValue)!]
        let rotated = false
        coordinator.section = section
        coordinator.media = media
        coordinator.shouldScreenRotate = rotated
        coordinator.coordinate(to: .detail)
    }
}

// MARK: - ViewInstantiable Implementation

extension ShowcaseView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension ShowcaseView: ViewProtocol {}

// MARK: - Private UI Implementation

extension ShowcaseView {
    func setupGradients() {
        bottomGradientView.addGradientLayer(colors: [.clear, .black.withAlphaComponent(0.5)], locations: [0.0, 0.66])
    }
}
