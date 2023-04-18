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
        viewDidUnbindObservers()
        viewModel = nil
    }
    
    override func viewDidLoad() {
        viewDidBindObservers()
    }
    
    override func viewDidBindObservers() {
        guard let controller = viewModel.coordinator.viewController,
              let segmentState = controller.segmentControlView?.viewModel.state.value else { return }
        
        viewModel.state.observe(on: self) { [weak self] state in
            guard let self = self, let state = state else { return }
            
            self.viewModel.stateDidChange(state)
            
            controller.navigationOverlayView?.viewModel.navigationViewStateDidChange(segmentState)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `NavigationView` observers.")
    }
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        guard let state = NavigationView.State(rawValue: sender.tag) else { return }
        
        viewModel.stateDidChange(state)
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
        case .airPlay: return Localization.TabBar.Home.Navigation().airPlay
        case .account: return Localization.TabBar.Home.Navigation().account
        case .search: return Localization.TabBar.Home.Navigation().search
        }
    }
}
