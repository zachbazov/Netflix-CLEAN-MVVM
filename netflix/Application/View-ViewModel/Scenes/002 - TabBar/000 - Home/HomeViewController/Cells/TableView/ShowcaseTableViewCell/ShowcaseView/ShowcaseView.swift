//
//  ShowcaseView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var cellViewModel: ShowcaseTableViewCellViewModel { get }
    
    var panelView: PanelView? { get }
    var gradient: GradientView? { get }
    
    func createViewModel()
    func createPanelView()
    
    func didTap()
    func removeNavigationGradientFromSuperview()
    func updateColors(_ colors: [Color])
    func drawGradientIfNeeded(_ condition: Bool)
    
    func setDarkBottomGradient()
    func setPosterStroke()
    func setGenres(attributed string: NSMutableAttributedString)
    func setMediaType()
    func setGestures()
    func setGradient(for image: UIImage)
    func setLogo(image: UIImage)
    func setPoster(image: UIImage)
    
    func loadResources()
}

// MARK: - ShowcaseView Type

final class ShowcaseView: View<ShowcaseViewViewModel> {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private(set) weak var posterImageView: UIImageView!
    @IBOutlet private(set) weak var logoImageView: UIImageView!
    @IBOutlet private weak var bottomGradientView: UIView!
    @IBOutlet private(set) weak var genresLabel: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private(set) weak var panelViewContainer: UIView!
    
    fileprivate let cellViewModel: ShowcaseTableViewCellViewModel
    
    private(set) var panelView: PanelView?
    private(set) var gradient: GradientView?
    
    init(on parent: UIView, with viewModel: ShowcaseTableViewCellViewModel?) {
        guard let viewModel = viewModel else { fatalError("Unexpected \(ShowcaseTableViewCellViewModel.self) value.") }
        self.cellViewModel = viewModel
        
        super.init(frame: .zero)
        
        self.nibDidLoad()
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func dataWillLoad() {
        loadResources()
    }
    
    override func viewDidLoad() {
        viewWillDeploySubviews()
        viewWillConfigure()
        viewWillConstraint()
        dataWillLoad()
    }
    
    override func viewWillDeploySubviews() {
        createViewModel()
        createPanelView()
    }
    
    override func viewWillConfigure() {
        guard let viewModel = viewModel else { return }
        
        setDarkBottomGradient()
        setBackgroundColor(.clear)
        setPosterStroke()
        setGenres(attributed: viewModel.attributedGenres)
        setMediaType()
        setGestures()
    }
    
    override func viewWillConstraint() {
        contentView.constraintToSuperview(self)
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
        logoImageView.image = nil
        genresLabel.attributedText = nil
    }
    
    override func viewWillDeallocate() {
        panelView?.removeFromSuperview()
        panelView = nil
        
        removeNavigationGradientFromSuperview()
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension ShowcaseView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension ShowcaseView: ViewProtocol {
    fileprivate func createViewModel() {
        guard let controller = cellViewModel.coordinator.viewController,
              let homeViewModel = controller.viewModel
        else { return }
        
        let state = homeViewModel.dataSourceState.value
        let media = homeViewModel.showcases[state]
        
        viewModel = ShowcaseViewViewModel(media: media, with: homeViewModel)
    }
    
    fileprivate func createPanelView() {
        panelView = PanelView(on: panelViewContainer, with: cellViewModel)
    }
    
    @objc
    func didTap() {
        guard let controller = viewModel?.coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let coordinator = homeViewModel.coordinator
        else { return }
        
        let state = homeViewModel.dataSourceState.value
        let section = controller.navigationOverlay?.viewModel?.category.toSection()
        let index = HomeTableViewDataSource.State(rawValue: state.rawValue)!
        let media = homeViewModel.showcases[index]
        let rotated = false
        
        homeViewModel.detailSection = section
        homeViewModel.detailMedia = media
        homeViewModel.shouldScreenRotate = rotated
        
        coordinator.coordinate(to: .detail)
    }
    
    fileprivate func removeNavigationGradientFromSuperview() {
        guard let controller = viewModel.coordinator.viewController else { return }
        
        controller.navigationView?.removeGradient()
    }
    
    fileprivate func updateColors(_ colors: [Color]) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        navigation.viewModel?.setColors(colors)
    }
    
    fileprivate func drawGradientIfNeeded(_ condition: Bool) {
        guard let controller = viewModel?.coordinator.viewController,
              let navigation = controller.navigationView
        else { return }
        
        guard condition else { return }
        
        navigation.apply(.gradient)
    }
    
    func setDarkBottomGradient() {
        bottomGradientView.addGradientLayer(colors: [.clear, .black.withAlphaComponent(0.66)],
                                            locations: [0.0, 0.66])
    }
    
    fileprivate func setPosterStroke() {
        let gradient = UIImage.fillGradientStroke(bounds: posterImageView.bounds,
                                                  colors: [.white.withAlphaComponent(0.5), .clear])
        let color = UIColor(patternImage: gradient).cgColor
        
        posterImageView?.layer.borderColor = color
        posterImageView?.layer.borderWidth = 1.5
        posterImageView?.layer.cornerRadius = 12.0
    }
    
    fileprivate func setGradient(for image: UIImage) {
        guard gradient == nil else { return }
        
        guard let controller = viewModel?.coordinator.viewController,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        let colors = image.averageColorPalette()
        updateColors(colors.toColorArray())
        
        let condition = !browseOverlay.viewModel.isPresented.value
        drawGradientIfNeeded(condition)
        
        gradient = GradientView(on: contentView)
            .draw(with: colors)
    }
    
    fileprivate func setPoster(image: UIImage) {
        posterImageView.image = image
    }
    
    fileprivate func setLogo(image: UIImage) {
        logoImageView.image = image
    }
    
    fileprivate func setGenres(attributed string: NSMutableAttributedString) {
        genresLabel.attributedText = string
    }
    
    fileprivate func setGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setMediaType() {
        guard let viewModel = viewModel,
              let typeImagePath = viewModel.typeImagePath
        else { return }
        
        typeImageView.image = UIImage(named: typeImagePath)
    }
    
    fileprivate func loadResources() {
        prepareForReuse()
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setGradient(for: image)
                    self.setPoster(image: image)
                }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setLogo(image: image)
                }
            }
    }
}
