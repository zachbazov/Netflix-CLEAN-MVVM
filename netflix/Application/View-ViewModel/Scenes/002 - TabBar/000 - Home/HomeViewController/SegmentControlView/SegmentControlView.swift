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
    @IBOutlet private weak var allButton: UIButton!
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
        
        viewModel?.segment.observe(on: self) { [weak self] segment in
            guard let self = self else { return }
            
            self.buttonsDidUpdate(for: segment)
            self.leadingConstraintDidUpdate(for: segment)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        viewModel.segment.remove(observer: self)
        
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
            allButton.isHidden(true)
            tvShowsButton.isHidden(false)
            moviesButton.isHidden(false)
            categoriesButton.isHidden(false)
        case .all:
            xButton.isHidden(false)
            allButton.isHidden(false)
            tvShowsButton.isHidden(true)
            moviesButton.isHidden(true)
            categoriesButton.isHidden(false)
        case .tvShows:
            xButton.isHidden(false)
            allButton.isHidden(true)
            tvShowsButton.isHidden(false)
            moviesButton.isHidden(true)
            categoriesButton.isHidden(false)
        case .movies:
            xButton.isHidden(false)
            allButton.isHidden(true)
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
        case .all:
            break
        case .tvShows, .movies:
            stackViewLeadingConstraint.constant = 16.0
        case .categories:
            break
        }
    }
    
    func stateDidChange(_ state: SegmentControlView.State) {
        guard let controller = viewModel.coordinator.viewController,
              let homeViewModel = controller.viewModel,
              let navigationOverlay = controller.navigationOverlayView,
              let browseOverlay = controller.browseOverlayView
        else { return }
        
        guard let section = navigationOverlay.viewModel?.category.toSection() else { return }
        
        switch state {
        case .main:
            viewModel.isSegmentSelected = false
            
            homeViewModel.dataSourceState.value = .all
            
            navigationOverlay.viewModel?.state.value = .main
            
            browseOverlay.viewModel?.isPresented.value = false
            
            controller.dataSource?.style.addGradient()
        case .all:
            if viewModel.isSegmentSelected {
                navigationOverlay.viewModel?.isPresented.value = true
                navigationOverlay.viewModel?.state.value = .main
                
                return
            }
            
            viewModel.isSegmentSelected = true
            
            if homeViewModel.dataSourceState.value != .all {
                homeViewModel.dataSourceState.value = .all
                
                browseOverlay.viewModel?.section.value = section
            }
        case .tvShows:
            if viewModel.isSegmentSelected {
                navigationOverlay.viewModel?.isPresented.value = true
                navigationOverlay.viewModel?.state.value = .main
                
                return
            }
            
            viewModel.isSegmentSelected = true
            
            if homeViewModel.dataSourceState.value != .tvShows {
                homeViewModel.dataSourceState.value = .tvShows
                
                browseOverlay.viewModel?.section.value = section
            }
        case .movies:
            if viewModel.isSegmentSelected {
                navigationOverlay.viewModel?.isPresented.value = true
                navigationOverlay.viewModel?.state.value = .main
                
                return
            }
            
            viewModel.isSegmentSelected = true
            
            if homeViewModel.dataSourceState.value != .movies {
                homeViewModel.dataSourceState.value = .movies
                
                browseOverlay.viewModel?.section.value = section
            }
        case .categories:
            navigationOverlay.viewModel?.isPresented.value = true
            navigationOverlay.viewModel?.state.value = .genres
        }
    }
}

// MARK: - Private UI Implementation

extension SegmentControlView {
    private func setupButtons() {
        allButton
            .border(.white.withAlphaComponent(0.3), width: 1.5)
            .round()
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
        case all
        case tvShows
        case movies
        case categories
    }
}

// MARK: - Valuable Implementation

extension SegmentControlView.State: Valuable {
    var stringValue: String {
        switch self {
        case .main: return Localization.TabBar.Home.SegmentControl().main
        case .all: return Localization.TabBar.Home.SegmentControl().all
        case .tvShows: return Localization.TabBar.Home.SegmentControl().tvShows
        case .movies: return Localization.TabBar.Home.SegmentControl().movies
        case .categories: return Localization.TabBar.Home.SegmentControl().categories
        }
    }
}
