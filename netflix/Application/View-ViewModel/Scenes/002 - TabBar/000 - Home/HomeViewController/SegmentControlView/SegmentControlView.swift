//
//  SegmentControlView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - NavigationView Type

final class SegmentControlView: View<SegmentControlViewViewModel> {
    @IBOutlet private(set) weak var stackView: UIStackView!
    @IBOutlet private(set) weak var xButton: UIButton!
    @IBOutlet private(set) weak var tvShowsButton: UIButton!
    @IBOutlet private(set) weak var moviesButton: UIButton!
    @IBOutlet private(set) weak var categoriesButton: UIButton!
    @IBOutlet private(set) weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.viewModel = SegmentControlViewViewModel(with: viewModel)
        
        self.viewDidLoad()
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewDidBindObservers()
    }
    
    override func viewDidConfigure() {
        tvShowsButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        tvShowsButton.layer.borderWidth = 1.5
        tvShowsButton.layer.cornerRadius = 18.0
        moviesButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        moviesButton.layer.borderWidth = 1.5
        moviesButton.layer.cornerRadius = 20.0
        categoriesButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        categoriesButton.layer.borderWidth = 1.5
        categoriesButton.layer.cornerRadius = 18.0
    }
    
    override func viewDidBindObservers() {
        guard let controller = viewModel.coordinator.viewController else { return }
        
        viewModel.state.observe(on: self) { state in
            controller.navigationOverlayView?.viewModel.navigationViewStateDidChange(state)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `NavigationView` observers.")
    }
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard let state = SegmentControlView.State(rawValue: sender.tag) else { return }
        
        viewModel.state.value = state
        
        switch state {
        case .main:
            xButton.isHidden(true)
            tvShowsButton.isHidden(false)
            moviesButton.isHidden(false)
            categoriesButton.isHidden(false)
            
            stackViewLeadingConstraint.constant = 24.0
        case .tvShows:
            xButton.isHidden(false)
            tvShowsButton.isHidden(false)
            moviesButton.isHidden(true)
            categoriesButton.isHidden(false)
            
            stackViewLeadingConstraint.constant = 16.0
        case .movies:
            xButton.isHidden(false)
            tvShowsButton.isHidden(true)
            moviesButton.isHidden(false)
            categoriesButton.isHidden(false)
            
            stackViewLeadingConstraint.constant = 16.0
        case .categories:
            break
        }
        
        animateUsingSpring(withDuration: 0.33, withDamping: 0.7, initialSpringVelocity: 0.7)
    }
}

// MARK: - ViewInstantiable Implementation

extension SegmentControlView: ViewInstantiable {}

// MARK: - State Type

extension SegmentControlView {
    /// State representation type.
    enum State: Int, CaseIterable {
        case main
        case tvShows
        case movies
        case categories
    }
}

// MARK: - Valuable Implementation

extension SegmentControlView.State: Valuable {
    var stringValue: String {
        switch self {
        case .main: return Localization.TabBar.Home.Navigation().home
        case .tvShows: return Localization.TabBar.Home.Navigation().tvShows
        case .movies: return Localization.TabBar.Home.Navigation().movies
        case .categories: return Localization.TabBar.Home.Navigation().categories
        }
    }
}
