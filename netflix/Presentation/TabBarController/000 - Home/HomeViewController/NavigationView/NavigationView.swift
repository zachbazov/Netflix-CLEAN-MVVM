//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

final class NavigationView: UIView, ViewInstantiable {
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var homeItemViewContainer: UIView!
    @IBOutlet private weak var airPlayItemViewContainer: UIView!
    @IBOutlet private weak var accountItemViewContainer: UIView!
    @IBOutlet private(set) weak var tvShowsItemViewContainer: UIView!
    @IBOutlet private(set) weak var moviesItemViewContainer: UIView!
    @IBOutlet private(set) weak var categoriesItemViewContainer: UIView!
    @IBOutlet private(set) weak var itemsCenterXConstraint: NSLayoutConstraint!
    
    private(set) var viewModel: NavigationViewViewModel!
    var navigationOverlayView: NavigationOverlayView!
    
    private(set) var homeItemView: NavigationViewItem!
    private var airPlayItemView: NavigationViewItem!
    private var accountItemView: NavigationViewItem!
    private(set) var tvShowsItemView: NavigationViewItem!
    private(set) var moviesItemView: NavigationViewItem!
    private(set) var categoriesItemView: NavigationViewItem!
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
        self.accountItemView = NavigationViewItem(on: self.accountItemViewContainer, with: viewModel)
        self.tvShowsItemView = NavigationViewItem(on: self.tvShowsItemViewContainer, with: viewModel)
        self.moviesItemView = NavigationViewItem(on: self.moviesItemViewContainer, with: viewModel)
        self.categoriesItemView = NavigationViewItem(on: self.categoriesItemViewContainer, with: viewModel)
        let items: [NavigationViewItem] = [self.homeItemView, self.airPlayItemView,
                                           self.accountItemView, self.tvShowsItemView,
                                           self.moviesItemView, self.categoriesItemView]
        self.viewModel = NavigationViewViewModel(items: items, with: viewModel)
        /// Updates root coordinator's `navigationView` property.
        viewModel.coordinator?.viewController?.navigationView = self
        
        self.navigationOverlayView = NavigationOverlayView(with: viewModel)
        /// In-case of reallocation, reconfigure the view.
        self.viewDidReconfigure()
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        removeObservers()
        navigationOverlayView?.removeFromSuperview()
        navigationOverlayView = nil
        viewModel = nil
    }
}

extension NavigationView {
    private func setupGradientView() {
        let rect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: bounds.height)
        gradientView.addGradientLayer(
            frame: rect,
            colors: [.black.withAlphaComponent(0.9),
                     .black.withAlphaComponent(0.7),
                     .clear],
            locations: [0.0, 0.3, 1.0])
    }
    
    private func viewDidLoad() {
        setupObservers()
        viewDidConfigure()
    }
    
    private func viewDidConfigure() {
        setupGradientView()
    }
    /// Reconfigure the view once reallocation occurs by changing home's data source state.
    private func viewDidReconfigure() {
        let tabBarViewModel = Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel
        if tabBarViewModel?.latestHomeDataSourceState == .all {
            self.homeItemView.viewModel.isSelected = true
            self.viewModel.state.value = .home
        } else if tabBarViewModel?.latestHomeDataSourceState == .series {
            tabBarViewModel?.latestHomeNavigationState = .tvShows
            self.tvShowsItemView.viewModel.isSelected = true
            self.viewModel.state.value = .tvShows
        } else if tabBarViewModel?.latestHomeDataSourceState == .films {
            tabBarViewModel?.latestHomeNavigationState = .movies
            self.moviesItemView.viewModel.isSelected = true
            self.viewModel.state.value = .movies
        }
    }
}

extension NavigationView {
    private func setupObservers() {
        viewModel.state.observe(on: self) { [weak self] state in
            self?.viewModel.stateDidChange(state)
            self?.navigationOverlayView.viewModel.navigationViewStateDidChange(state)
        }
    }
    
    func removeObservers() {
        printIfDebug("Removed `NavigationView` observers.")
        viewModel.state.remove(observer: self)
    }
}

extension NavigationView {
    /// Item representation type.
    enum State: Int, CaseIterable {
        case home
        case airPlay
        case account
        case tvShows
        case movies
        case categories
    }
}

extension NavigationView.State: Valuable {
    var stringValue: String {
        switch self {
        case .home: return Localization.TabBar.Home.Navigation().home
        case .tvShows: return Localization.TabBar.Home.Navigation().tvShows
        case .movies: return Localization.TabBar.Home.Navigation().movies
        case .categories: return Localization.TabBar.Home.Navigation().categories
        case .airPlay: return Localization.TabBar.Home.Navigation().airPlay
        case .account: return Localization.TabBar.Home.Navigation().account
        }
    }
}
