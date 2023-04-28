//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - NavigationView Type

final class NavigationView: View<NavigationViewViewModel> {
    @IBOutlet private(set) weak var airPlayButton: UIButton!
    @IBOutlet private(set) weak var profileLabel: UILabel!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        
        self.nibDidLoad()
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.viewModel = NavigationViewViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewModel.getUserProfiles()
    }
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard let state = NavigationView.State(rawValue: sender.tag) else { return }
        
        stateDidChange(state)
    }
    
    /// Controls the navigation presentation of items.
    /// - Parameter state: Corresponding state.
    func stateDidChange(_ state: NavigationView.State) {
        switch state {
        case .airPlay:
            airPlayButton.asRoutePickerView()
        case .search:
            viewModel.coordinator.coordinate(to: .search)
        case .account:
            viewModel.coordinator.coordinate(to: .account)
        }
    }
}

// MARK: - ViewInstantiable Implementation

extension NavigationView: ViewInstantiable {}

// MARK: - State Type

extension NavigationView {
    /// Item representation type.
    enum State: Int, CaseIterable {
        case airPlay
        case search
        case account
    }
}

// MARK: - Valuable Implementation

extension NavigationView.State: Valuable {
    var stringValue: String {
        switch self {
        case .airPlay: return Localization.TabBar.Home.SegmentControl().airPlay
        case .account: return Localization.TabBar.Home.SegmentControl().account
        case .search: return Localization.TabBar.Home.SegmentControl().search
        }
    }
}
