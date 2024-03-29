//
//  NavigationBarView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    func buttonDidTap(_ sender: UIButton)
    func configureProfileLabel()
}

// MARK: - NavigationBarView Type

final class NavigationBarView: UIView, View {
    @IBOutlet private(set) weak var airPlayButton: UIButton!
    @IBOutlet private(set) weak var profileLabel: UILabel!
    
    var viewModel: NavigationBarViewModel!
    
    deinit {
        viewWillDeallocate()
    }
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        super.init(frame: .zero)
        
        self.viewModel = NavigationBarViewModel(with: viewModel)
        
        self.nibDidLoad()
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func viewDidLoad() {
        viewWillDeploySubviews()
    }
    
    func viewWillDeploySubviews() {
        configureProfileLabel()
    }
    
    func viewWillDeallocate() {
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewInstantiable Implementation

extension NavigationBarView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension NavigationBarView: ViewProtocol {
    @IBAction fileprivate func buttonDidTap(_ sender: UIButton) {
        guard let state = NavigationBarView.State(rawValue: sender.tag) else { return }
        
        viewModel?.stateDidChange(state)
    }
    
    fileprivate func configureProfileLabel() {
        viewModel?.getUserProfiles() { [weak self] profile in
            guard let self = self, let profile = profile else { return }
            
            self.profileLabel?.text = profile.name
        }
    }
}

// MARK: - State Type

extension NavigationBarView {
    /// Item representation type.
    enum State: Int, CaseIterable {
        case airPlay
        case search
        case account
    }
}

// MARK: - Valuable Implementation

extension NavigationBarView.State: Valuable {
    var stringValue: String {
        switch self {
        case .airPlay: return Localization.TabBar.Home.NavigationView().airPlay
        case .account: return Localization.TabBar.Home.NavigationView().account
        case .search: return Localization.TabBar.Home.NavigationView().search
        }
    }
}
