//
//  ShowcaseView.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var panelView: PanelView? { get }
    var gradient: GradientView? { get }
    var cellViewModel: ShowcaseTableViewCellViewModel { get }
    
    func createViewModel()
    func createPanelView()
    
    func didTap()
    
    func analyzeColors(for image: UIImage) -> [UIColor]
    func setDarkBottomGradient()
    func setGradient(for image: UIImage)
    func setPosterShadow(for color: UIColor)
    func setPosterStroke()
    func setGenres(attributed string: NSMutableAttributedString)
    func setMediaType()
    func setGestures()
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
    
    private(set) var panelView: PanelView?
    private(set) var gradient: GradientView?
    
    fileprivate let cellViewModel: ShowcaseTableViewCellViewModel
    
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
        
        gradient?.layer.removeFromSuperlayer()
        gradient?.removeFromSuperview()
        gradient = nil
        
        viewModel = nil
        
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
        
        self.viewModel = ShowcaseViewViewModel(media: media, with: homeViewModel)
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
        let section = homeViewModel.section(at: .resumable)
        let media = homeViewModel.showcases[HomeTableViewDataSource.State(rawValue: state.rawValue)!]
        let rotated = false
        
        homeViewModel.detailSection = section
        homeViewModel.detailMedia = media
        homeViewModel.shouldScreenRotate = rotated
        
        coordinator.coordinate(to: .detail)
    }
    
    fileprivate func analyzeColors(for image: UIImage) -> [UIColor] {
        let c1 = image.averageColor!
        let c2 = image.areaAverage().darkerColor(for: c1)
        let c3 = c2.darkerColor(for: c2)
        let c4 = UIColor.black
        return [c1, c2, c3, c4]
    }
    
    fileprivate func setGradient(for image: UIImage) {
        guard let controller = viewModel?.coordinator.viewController else { return }
        
        let colors = analyzeColors(for: image)
        
        gradient = GradientView(on: contentView).applyGradient(with: colors)
        
        controller.dataSource?.style.update(colors: colors)
        
        setPosterShadow(for: colors[2])
    }
    
    fileprivate func setPosterShadow(for color: UIColor) {
        contentView.layer.shadow(color, radius: 24.0, opacity: 1.0)
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
        guard let viewModel = viewModel, viewModel.typeImagePath.isNotEmpty else { return }
        
        typeImageView.image = UIImage(named: viewModel.typeImagePath)
    }
    
    fileprivate func loadResources() {
        prepareForReuse()
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                mainQueueDispatch {
                    self.setPoster(image: image)
                    self.setGradient(for: image)
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
