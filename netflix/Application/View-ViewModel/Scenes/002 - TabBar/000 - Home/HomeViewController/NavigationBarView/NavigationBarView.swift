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
}

// MARK: - NavigationBarView Type

final class NavigationBarView: View<NavigationBarViewModel> {
    @IBOutlet private(set) weak var airPlayButton: UIButton!
    @IBOutlet private(set) weak var profileLabel: UILabel!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        
        self.nibDidLoad()
        
        self.viewModel = NavigationBarViewModel(with: viewModel)
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewModel?.getUserProfiles()
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
