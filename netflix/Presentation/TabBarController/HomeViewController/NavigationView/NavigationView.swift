//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 16/09/2022.
//

import UIKit

final class NavigationView: UIView, ViewInstantiable {
    enum State: Int, CaseIterable {
        case home
        case airPlay
        case account
        case tvShows
        case movies
        case categories
    }
    
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
    
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: parent.bounds)
        self.nibDidLoad()
        parent.addSubview(self)
        self.constraintToSuperview(parent)
        
        self.homeItemView = NavigationViewItem(onParent: self.homeItemViewContainer, with: viewModel)
        self.airPlayItemView = NavigationViewItem(onParent: self.airPlayItemViewContainer, with: viewModel)
        self.accountItemView = NavigationViewItem(onParent: self.accountItemViewContainer, with: viewModel)
        self.tvShowsItemView = NavigationViewItem(onParent: self.tvShowsItemViewContainer, with: viewModel)
        self.moviesItemView = NavigationViewItem(onParent: self.moviesItemViewContainer, with: viewModel)
        self.categoriesItemView = NavigationViewItem(onParent: self.categoriesItemViewContainer, with: viewModel)
        let items: [NavigationViewItem] = [self.homeItemView, self.airPlayItemView,
                                           self.accountItemView, self.tvShowsItemView,
                                           self.moviesItemView, self.categoriesItemView]
        let actions = NavigationViewViewModelActions(
            stateDidChange: { state in
                let navigation = viewModel.coordinator?.viewController?.navigationView
                navigation?.viewModel.stateDidChange(state)
                navigation?.navigationOverlayView.viewModel.navigationViewStateDidChange(state)
            })
        self.viewModel = NavigationViewViewModel(items: items, actions: actions, with: viewModel)
        
        /// Updates root coordinator's `navigationView` property.
        viewModel.coordinator?.viewController?.navigationView = self
        
        self.navigationOverlayView = NavigationOverlayView(with: viewModel)
        
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
    
    private func setupObservers() {
        viewModel.state.observe(on: self) { [weak self] state in
            self?.viewModel?.actions.stateDidChange(state)
        }
    }
    
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
    
    private func viewDidReconfigure() {
        /// Reconfigure the view once reinitialized.
        if Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel.tableViewState.value == .all {
            self.homeItemView.viewModel.isSelected = true
            self.viewModel.state.value = .home
        } else if Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel.tableViewState.value == .series {
            Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel.lastSelection = .tvShows
            self.tvShowsItemView.viewModel.isSelected = true
            self.viewModel.state.value = .tvShows
        } else if Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel.tableViewState.value == .films {
            Application.current.rootCoordinator.tabCoordinator.viewController?.viewModel.lastSelection = .movies
            self.moviesItemView.viewModel.isSelected = true
            self.viewModel.state.value = .movies
        }
    }
    
    func removeObservers() {
        printIfDebug("Removed `NavigationView` observers.")
        viewModel.state.remove(observer: self)
    }
}

extension NavigationView.State: Valuable {
    var stringValue: String {
        switch self {
        case .home: return "Home"
        case .tvShows: return "TV Shows"
        case .movies: return "Movies"
        case .categories: return "Categories"
        default: return .init()
        }
    }
}