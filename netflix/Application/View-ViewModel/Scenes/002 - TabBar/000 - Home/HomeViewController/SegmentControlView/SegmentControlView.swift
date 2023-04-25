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
        tvShowsButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        tvShowsButton.layer.borderWidth = 1.5
        tvShowsButton.layer.cornerRadius = 18.0
        moviesButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        moviesButton.layer.borderWidth = 1.5
        moviesButton.layer.cornerRadius = 20.0
        categoriesButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        categoriesButton.layer.borderWidth = 1.5
        categoriesButton.layer.cornerRadius = 18.0
    }
    
    override func viewDidBindObservers() {
        viewModel.state.observe(on: self) { [weak self] state in
            self?.stateDidChange(state)
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
    
    func stateDidChange(_ state: SegmentControlView.State) {
        guard let homeViewController = viewModel.coordinator.viewController,
              let homeViewModel = homeViewController.viewModel,
              let navigationOverlayView = homeViewController.navigationOverlayView,
              let browseOverlayView = homeViewController.browseOverlayView else {
            return
        }
        
        switch state {
        case .main:
            // In-case the user already interacting with browse's overlay, and wants to dismiss it.
            if !navigationOverlayView.viewModel.isPresented.value && browseOverlayView.viewModel.isPresented {
                // Set the navigation settings by the latest state stored value.
                viewModel.hasHomeExpanded = false
                viewModel.hasTvExpanded = viewModel.latestState == .tvShows ? true : false
                viewModel.hasMoviesExpanded = viewModel.latestState == .movies ? true : false
                // Restore the navigation view state.
                viewModel.state.value = viewModel.latestState
                // Dismiss browse's overlay.
                browseOverlayView.viewModel.isPresented = false
                
                homeViewController.dataSource?.style.addGradient()
            // In-case the user wants to navigate back home's state.
            } else if homeViewModel.dataSourceState.value != .all
                        && !navigationOverlayView.viewModel.isPresented.value
                        && !browseOverlayView.viewModel.isPresented {
                viewModel.hasHomeExpanded = false
                viewModel.hasTvExpanded = false
                viewModel.hasMoviesExpanded = false
                homeViewModel.dataSourceState.value = .all
                viewModel.latestState = .main
                return
            // Default case.
            } else if homeViewModel.dataSourceState.value == .all
                        && !navigationOverlayView.viewModel.isPresented.value
                        && !browseOverlayView.viewModel.isPresented {
                return
            }
            
            viewModel.hasHomeExpanded = true
        case .tvShows:
            // In-case the user wants to navigate to either tv-shows or movies state.
            if viewModel.hasTvExpanded || browseOverlayView.viewModel.isPresented {
                // Set the navigation overlay state to main.
                navigationOverlayView.viewModel.state = .main
                // Present the overlay.
                navigationOverlayView.viewModel.isPresented.value = true
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
            if viewModel.hasMoviesExpanded || browseOverlayView.viewModel.isPresented {
                navigationOverlayView.viewModel.state = .main
                navigationOverlayView.viewModel.isPresented.value = true
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
            navigationOverlayView.viewModel.state = .genres
            // Present the overlay.
            navigationOverlayView.viewModel.isPresented.value = true
        }
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
