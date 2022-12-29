//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

// MARK: - NavigationView Type

final class NavigationView: UIView, ViewInstantiable {
    
    // MARK: Outlet Properties
    
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var homeItemViewContainer: UIView!
    @IBOutlet private weak var airPlayItemViewContainer: UIView!
    @IBOutlet private weak var accountItemViewContainer: UIView!
    @IBOutlet private(set) weak var tvShowsItemViewContainer: UIView!
    @IBOutlet private(set) weak var moviesItemViewContainer: UIView!
    @IBOutlet private(set) weak var categoriesItemViewContainer: UIView!
    @IBOutlet private(set) weak var itemsCenterXConstraint: NSLayoutConstraint!
    
    // MARK: Type's Properties
    
    private(set) var viewModel: NavigationViewViewModel!
    var navigationOverlayView: NavigationOverlayView!
    
    private(set) var homeItemView: NavigationViewItem!
    private var airPlayItemView: NavigationViewItem!
    private var accountItemView: NavigationViewItem!
    private(set) var tvShowsItemView: NavigationViewItem!
    private(set) var moviesItemView: NavigationViewItem!
    private(set) var categoriesItemView: NavigationViewItem!
    
    // MARK: Initializer
    
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
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: Deinitializer
    
    deinit {
        removeObservers()
        navigationOverlayView?.removeFromSuperview()
        navigationOverlayView = nil
        viewModel = nil
    }
}

// MARK: - UI Setup

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
}

// MARK: - Observers

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

// MARK: - State Type

extension NavigationView {
    /// Item representation type.
    enum State: Int, CaseIterable {
        case home
        case airPlay
        case account
        case tvShows
        case movies
        case categories
        case allCategories
    }
}

// MARK: - Valuable Implementation

extension NavigationView.State: Valuable {
    var stringValue: String {
        switch self {
        case .home: return Localization.TabBar.Home.Navigation().home
        case .tvShows: return Localization.TabBar.Home.Navigation().tvShows
        case .movies: return Localization.TabBar.Home.Navigation().movies
        case .categories: return Localization.TabBar.Home.Navigation().categories
        case .airPlay: return Localization.TabBar.Home.Navigation().airPlay
        case .account: return Localization.TabBar.Home.Navigation().account
        case .allCategories: return Localization.TabBar.Home.Navigation().allCategories
        }
    }
}
