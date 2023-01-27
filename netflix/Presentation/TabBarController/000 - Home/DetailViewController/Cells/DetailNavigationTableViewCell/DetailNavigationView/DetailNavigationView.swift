//
//  DetailNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailNavigationView Type

final class DetailNavigationView: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private(set) weak var leadingViewContainer: UIView!
    @IBOutlet private(set) weak var centerViewContainer: UIView!
    @IBOutlet private(set) weak var trailingViewContrainer: UIView!
    
    // MARK: Type's Properties
    
    let viewModel: DetailViewModel
    private(set) var leadingItem: DetailNavigationViewItem!
    private(set) var centerItem: DetailNavigationViewItem!
    private(set) var trailingItem: DetailNavigationViewItem!
    
    // MARK: Initializer
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.leadingItem = DetailNavigationViewItem(navigationView: self, on: self.leadingViewContainer, with: viewModel)
        self.centerItem = DetailNavigationViewItem(navigationView: self, on: self.centerViewContainer, with: viewModel)
        self.trailingItem = DetailNavigationViewItem(navigationView: self, on: self.trailingViewContrainer, with: viewModel)
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Deinitializer
    
    deinit {
        leadingItem = nil
        centerItem = nil
        trailingItem = nil
    }
}

// MARK: - UI Setup

extension DetailNavigationView {
    private func viewDidLoad() {
        backgroundColor = .black
        
        // Initial settings based on the navigation view state.
        viewDidConfigure()
        stateDidChange(view: viewModel.navigationViewState.value == .episodes ? leadingItem : centerItem)
    }
    
    private func viewDidConfigure() {
        if viewModel.media.type == "series" {
            viewModel.navigationViewState.value = .episodes
            leadingViewContainer.isHidden(false)
            centerViewContainer.isHidden(true)
        } else {
            viewModel.navigationViewState.value = .trailers
            leadingViewContainer.isHidden(true)
            centerViewContainer.isHidden(false)
        }
    }
    
    func stateDidChange(view: DetailNavigationViewItem) {
        guard let state = State(rawValue: view.tag) else { return }
        viewModel.navigationViewState.value = state
        
        didSelectItem(view: view)
    }
    
    func didSelectItem(view: DetailNavigationViewItem) {
        guard let state = State(rawValue: view.tag) else { return }
        /// Release changes for the navigation red marker indicator view.
        redMarkerConstraintValueDidChange(for: state)
        /// Animate the view changes.
        animateUsingSpring(withDuration: 0.5, withDamping: 1.0, initialSpringVelocity: 1.0)
    }
}

// MARK: - Methods

extension DetailNavigationView {
    func redMarkerConstraintValueDidChange(for state: DetailNavigationView.State) {
        if case .episodes = state {
            leadingItem.widthConstraint.constant = leadingItem.bounds.width
            centerItem.widthConstraint.constant = .zero
            trailingItem.widthConstraint.constant = .zero
        }
        if case .trailers = state {
            leadingItem.widthConstraint.constant = .zero
            centerItem.widthConstraint.constant = centerItem.bounds.width
            trailingItem.widthConstraint.constant = .zero
        }
        if case .similarContent = state {
            leadingItem.widthConstraint.constant = .zero
            centerItem.widthConstraint.constant = .zero
            trailingItem.widthConstraint.constant = trailingItem.bounds.width
        }
    }
}

// MARK: - State Type

extension DetailNavigationView {
    /// Item representation type.
    enum State: Int {
        case episodes
        case trailers
        case similarContent
    }
}
