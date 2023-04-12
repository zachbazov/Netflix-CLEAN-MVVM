//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var homeItemView: NavigationViewItem! { get }
    var airPlayItemView: NavigationViewItem! { get }
    var searchItemView: NavigationViewItem! { get }
    var accountItemView: NavigationViewItem! { get }
}

// MARK: - NavigationView Type

final class NavigationView: View<NavigationViewViewModel> {
    @IBOutlet private(set) weak var topContainer: UIView!
    @IBOutlet private weak var homeItemViewContainer: UIView!
    @IBOutlet private weak var airPlayItemViewContainer: UIView!
    @IBOutlet private weak var searchItemViewContainer: UIView!
    @IBOutlet private weak var accountItemViewContainer: UIView!
    
    fileprivate(set) var homeItemView: NavigationViewItem!
    fileprivate var airPlayItemView: NavigationViewItem!
    fileprivate var searchItemView: NavigationViewItem!
    fileprivate var accountItemView: NavigationViewItem!
    
    /// Create a navigation view object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.homeItemView = NavigationViewItem(on: self.homeItemViewContainer, with: viewModel)
        self.airPlayItemView = NavigationViewItem(on: self.airPlayItemViewContainer, with: viewModel)
        self.searchItemView = NavigationViewItem(on: self.searchItemViewContainer, with: viewModel)
        self.accountItemView = NavigationViewItem(on: self.accountItemViewContainer, with: viewModel)
        let items: [NavigationViewItem] = [self.homeItemView, self.airPlayItemView,
                                           self.accountItemView, self.searchItemView]
        self.viewModel = NavigationViewViewModel(items: items, with: viewModel)
        
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
        guard let controller = viewModel.coordinator.viewController else { return }
        
        viewModel.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.viewModel.stateDidChange(state)
            
            controller.navigationOverlayView?.viewModel.navigationViewStateDidChange(state)
        }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `NavigationView` observers.")
    }
}

// MARK: - ViewInstantiable Implementation

extension NavigationView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension NavigationView: ViewProtocol {}

// MARK: - State Type

extension NavigationView {
    /// Item representation type.
    enum State: Int, CaseIterable {
        case home
        case airPlay
        case search
        case account
        case tvShows
        case movies
        case categories
    }
}

// MARK: - Valuable Implementation

extension NavigationView.State: Valuable {
    var stringValue: String {
        switch self {
        case .home: return Localization.TabBar.Home.Navigation().home
        case .airPlay: return Localization.TabBar.Home.Navigation().airPlay
        case .account: return Localization.TabBar.Home.Navigation().account
        case .tvShows: return Localization.TabBar.Home.Navigation().tvShows
        case .movies: return Localization.TabBar.Home.Navigation().movies
        case .categories: return Localization.TabBar.Home.Navigation().categories
        case .search: return ""
        }
    }
}
