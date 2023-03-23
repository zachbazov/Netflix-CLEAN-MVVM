//
//  DetailNavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var leadingItem: DetailNavigationViewItem! { get }
    var centerItem: DetailNavigationViewItem! { get }
    var trailingItem: DetailNavigationViewItem! { get }
    
    func stateDidChange(view: DetailNavigationViewItem)
    func didSelectItem(view: DetailNavigationViewItem)
    func redMarkerConstraintValueDidChange(for state: DetailNavigationView.State)
}

// MARK: - DetailNavigationView Type

final class DetailNavigationView: View<DetailViewModel> {
    @IBOutlet private(set) weak var leadingViewContainer: UIView!
    @IBOutlet private(set) weak var centerViewContainer: UIView!
    @IBOutlet private(set) weak var trailingViewContrainer: UIView!
    
    fileprivate(set) var leadingItem: DetailNavigationViewItem!
    fileprivate(set) var centerItem: DetailNavigationViewItem!
    fileprivate(set) var trailingItem: DetailNavigationViewItem!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: .zero)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        self.viewModel = viewModel
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
    
    override func viewDidLoad() {
        backgroundColor = .black
        
        // Initial settings based on the navigation view state.
        viewDidConfigure()
        stateDidChange(view: viewModel.navigationViewState.value == .episodes ? leadingItem : centerItem)
    }
    
    override func viewDidConfigure() {
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
}

// MARK: - ViewInstantiable Implementation

extension DetailNavigationView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension DetailNavigationView: ViewProtocol {
    func stateDidChange(view: DetailNavigationViewItem) {
        guard let state = State(rawValue: view.tag) else { return }
        viewModel.navigationViewState.value = state
        
        didSelectItem(view: view)
    }
    
    func didSelectItem(view: DetailNavigationViewItem) {
        guard let state = State(rawValue: view.tag) else { return }
        // Release changes for the navigation red marker indicator view.
        redMarkerConstraintValueDidChange(for: state)
        // Animate the view changes.
        animateUsingSpring(withDuration: 0.5, withDamping: 1.0, initialSpringVelocity: 1.0)
    }
    
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
