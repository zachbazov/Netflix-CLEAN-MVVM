//
//  DetailNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

final class DetailNavigationView: UIView, ViewInstantiable {
    @IBOutlet private(set) weak var leadingViewContainer: UIView!
    @IBOutlet private(set) weak var centerViewContainer: UIView!
    @IBOutlet private(set) weak var trailingViewContrainer: UIView!
    
    let viewModel: DetailViewModel
    private(set) var leadingItem: DetailNavigationViewItem!
    private(set) var centerItem: DetailNavigationViewItem!
    private(set) var trailingItem: DetailNavigationViewItem!
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.nibDidLoad()
        self.leadingItem = DetailNavigationViewItem(navigationView: self, on: self.leadingViewContainer, with: viewModel)
        self.centerItem = DetailNavigationViewItem(navigationView: self, on: self.centerViewContainer, with: viewModel)
        self.trailingItem = DetailNavigationViewItem(navigationView: self, on: self.trailingViewContrainer, with: viewModel)
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        leadingItem = nil
        centerItem = nil
        trailingItem = nil
    }
}

extension DetailNavigationView {
    private func viewDidLoad() {
        backgroundColor = .black
        /// Initial navigation state selection based on the navigation view state.
        stateDidChange(view: viewModel.navigationViewState.value == .episodes ? leadingItem : centerItem)
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

extension DetailNavigationView {
    /// Item representation type.
    enum State: Int {
        case episodes
        case trailers
        case similarContent
    }
}
