//
//  SegmentControlView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func buttonDidTap(_ sender: UIButton)
    func stateDidChange(_ state: SegmentControlView.State)
    func leadingConstraintDidUpdate(for state: SegmentControlView.State)
    func buttonsDidUpdate(for state: SegmentControlView.State)
    func updateState(_ state: SegmentControlView.State)
}

// MARK: - NavigationView Type

final class SegmentControlView: View<SegmentControlViewViewModel> {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var xButton: UIButton!
    @IBOutlet private weak var tvShowsButton: UIButton!
    @IBOutlet private weak var moviesButton: UIButton!
    @IBOutlet private weak var categoriesButton: UIButton!
    @IBOutlet private weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
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
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        viewDidUnbindObservers()
        
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewDidBindObservers()
        viewDidDeploySubviews()
    }
    
    override func viewDidDeploySubviews() {
        setupButtons()
    }
    
    override func viewDidBindObservers() {
        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.stateDidChange(state)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
}

// MARK: - ViewInstantiable Implementation

extension SegmentControlView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension SegmentControlView: ViewProtocol {
    @IBAction fileprivate func buttonDidTap(_ sender: UIButton) {
        guard let state = SegmentControlView.State(rawValue: sender.tag) else { return }
        
        updateState(state)
        buttonsDidUpdate(for: state)
        leadingConstraintDidUpdate(for: state)
        
        animateUsingSpring(withDuration: 0.33, withDamping: 0.7, initialSpringVelocity: 0.7)
    }
    
    fileprivate func updateState(_ state: SegmentControlView.State) {
        viewModel.state.value = state
    }
    
    fileprivate func buttonsDidUpdate(for state: SegmentControlView.State) {
        switch state {
        case .main:
            xButton.isHidden(true)
            tvShowsButton.isHidden(false)
            moviesButton.isHidden(false)
            categoriesButton.isHidden(false)
        case .tvShows:
            xButton.isHidden(false)
            tvShowsButton.isHidden(false)
            moviesButton.isHidden(true)
            categoriesButton.isHidden(false)
        case .movies:
            xButton.isHidden(false)
            tvShowsButton.isHidden(true)
            moviesButton.isHidden(false)
            categoriesButton.isHidden(false)
        case .categories:
            break
        }
    }
    
    fileprivate func leadingConstraintDidUpdate(for state: SegmentControlView.State) {
        switch state {
        case .main:
            stackViewLeadingConstraint.constant = 24.0
        case .tvShows:
            stackViewLeadingConstraint.constant = 16.0
        case .movies:
            stackViewLeadingConstraint.constant = 16.0
        case .categories:
            break
        }
    }
    
    fileprivate func stateDidChange(_ state: SegmentControlView.State) {
        guard let controller = viewModel.coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let navigationOverlay = controller.navigationOverlayView,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        switch state {
        case .main:
            // In-case the user already interacting with browse's overlay, and wants to dismiss it.
            if !navigationOverlay.viewModel.isPresented.value && browseOverlay.viewModel.isPresented.value {
                // Set the navigation settings by the latest state stored value.
                viewModel.hasHomeExpanded = false
                viewModel.hasTvExpanded = viewModel.latestState == .tvShows ? true : false
                viewModel.hasMoviesExpanded = viewModel.latestState == .movies ? true : false
                // Restore the navigation view state.
                viewModel.state.value = viewModel.latestState
                // Dismiss browse's overlay.
                browseOverlay.viewModel.isPresented.value = false
                
                controller.dataSource?.style.addGradient()
            // In-case the user wants to navigate back home's state.
            } else if homeViewModel.dataSourceState.value != .all
                        && !navigationOverlay.viewModel.isPresented.value
                        && !browseOverlay.viewModel.isPresented.value {
                viewModel.hasHomeExpanded = false
                viewModel.hasTvExpanded = false
                viewModel.hasMoviesExpanded = false
                homeViewModel.dataSourceState.value = .all
                viewModel.latestState = .main
                return
            // Default case.
            } else if homeViewModel.dataSourceState.value == .all
                        && !navigationOverlay.viewModel.isPresented.value
                        && !browseOverlay.viewModel.isPresented.value {
                return
            }
            
            viewModel.hasHomeExpanded = true
        case .tvShows:
            // In-case the user wants to navigate to either tv-shows or movies state.
            if viewModel.hasTvExpanded || browseOverlay.viewModel.isPresented.value {
                // Set the navigation overlay state to main.
                navigationOverlay.viewModel.state = .main
                // Present the overlay.
                navigationOverlay.viewModel.isPresented.value = true
                return
            // In-case either tv-shows or movies hasn't been expanded and a presented brose overlay.
            }
            // Else, set the navigation settings by state value.
            viewModel.hasHomeExpanded = false
            viewModel.hasTvExpanded = true
            viewModel.hasMoviesExpanded = false
            // Store the latest navigation state.
            viewModel.latestState = .tvShows
            // Set home's table view data source state to tv shows.
            homeViewModel.dataSourceState.value = .tvShows
        case .movies:
            // In-case the user wants to navigate to either tv-shows or movies state.
            if viewModel.hasMoviesExpanded || browseOverlay.viewModel.isPresented.value {
                navigationOverlay.viewModel.state = .main
                navigationOverlay.viewModel.isPresented.value = true
                return
            }
            // Else, set the navigation settings by state value.
            viewModel.hasHomeExpanded = false
            viewModel.hasTvExpanded = false
            viewModel.hasMoviesExpanded = true
            // Store the latest navigation state.
            viewModel.latestState = .movies
            // Set home's table view data source state to tv shows.
            homeViewModel.dataSourceState.value = .movies
        case .categories:
            // Set the navigation overlay state to genres.
            navigationOverlay.viewModel.state = .genres
            // Present the overlay.
            navigationOverlay.viewModel.isPresented.value = true
        }
    }
}

// MARK: - Private UI Implementation

extension SegmentControlView {
    private func setupButtons() {
        tvShowsButton
            .border(.white.withAlphaComponent(0.3), width: 1.5)
            .round()
        moviesButton
            .border(.white.withAlphaComponent(0.3), width: 1.5)
            .round()
        categoriesButton
            .border(.white.withAlphaComponent(0.3), width: 1.5)
            .round()
    }
}

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
