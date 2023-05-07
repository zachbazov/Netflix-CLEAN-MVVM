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
    func leadingConstraintDidUpdate(for state: SegmentControlView.State)
    func buttonsDidChange(for state: SegmentControlView.State)
}

// MARK: - SegmentControlView Type

final class SegmentControlView: View<SegmentControlViewModel> {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var xButton: UIButton!
    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var tvShowsButton: UIButton!
    @IBOutlet private weak var moviesButton: UIButton!
    @IBOutlet private weak var categoriesButton: UIButton!
    @IBOutlet private weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    private let parent: UIView
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        self.parent = parent
        
        super.init(frame: parent.bounds)
        
        self.nibDidLoad()
        
        self.viewModel = SegmentControlViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillBindObservers()
        viewWillDeploySubviews()
    }
    
    override func viewHierarchyWillConfigure() {
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
    }
    
    override func viewWillDeploySubviews() {
        configureButtons()
    }
    
    override func viewWillBindObservers() {
        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.buttonsDidChange(for: state)
            self.leadingConstraintDidUpdate(for: state)
            
            self.viewModel?.stateDidChange(state)
        }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension SegmentControlView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension SegmentControlView: ViewProtocol {
    @IBAction fileprivate func buttonDidTap(_ sender: UIButton) {
        guard let state = SegmentControlView.State(rawValue: sender.tag) else { return }
        
        viewModel?.stateWillChange(state)
        buttonsDidChange(for: state)
        
        animateUsingSpring(withDuration: 0.33, withDamping: 0.7, initialSpringVelocity: 0.7)
    }
    
    fileprivate func buttonsDidChange(for state: SegmentControlView.State) {
        
        leadingConstraintDidUpdate(for: state)
        
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
}

// MARK: - Private Presentation Implementation

extension SegmentControlView {
    private func configureButtons() {
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
