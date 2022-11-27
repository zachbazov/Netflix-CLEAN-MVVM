//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - HomeViewController class

final class HomeViewController: UIViewController {
    
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var navigationViewContainer: UIView!
    @IBOutlet private(set) var navigationViewTopConstraint: NSLayoutConstraint!
    
    private(set) var viewModel: HomeViewModel!
    private var diProvider: HomeViewDIProvider!
    private(set) var dataSource: HomeTableViewDataSource!
    private(set) var navigationView: NavigationView!
    private(set) var categoriesOverlayView: CategoriesOverlayView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    deinit {
        navigationView = nil
        categoriesOverlayView = nil
        dataSource = nil
        diProvider = nil
        viewModel = nil
    }
    
    /// Creates an `HomeViewController` instance using storyboard.
    /// - Parameter viewModel: View controller's view model.
    /// - Returns: `HomeViewController` instance.
    static func create(with viewModel: HomeViewModel) -> HomeViewController {
        let view = Storyboard(withOwner: TabBarController.self,
                              launchingViewController: HomeViewController.self)
            .instantiate() as! HomeViewController
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDependencies()
        setupBehaviors()
        setupSubviews()
        setupObservers()
        viewModel.viewWillLoad()
    }
    
    private func setupDependencies() {
        /// Invokes `HomeViewDIProvider` dependency inversion object.
        diProvider = tabBarSceneDIProvider.createHomeViewDIProvider(launchingViewController: self)
        /// Passes `diProvider` pointer to view model.
        viewModel.homeViewDIProvider = diProvider
    }
    
    private func setupBehaviors() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    private func setupSubviews() {
        setupDataSource()
        setupNavigationView()
        setupCategoriesOverlayView()
    }
    
    private func setupObservers() {
        tableViewState(in: viewModel)
        presentedDisplayMedia(in: viewModel)
    }
    
    private func setupDataSource() {
        /// Filters the sections based on the data source state.
        viewModel.filter(sections: viewModel.sections)
        /// Creates the table view data source's actions.
        let actions = diProvider.createHomeTableViewDataSourceActions()
        /// Initializes the data source.
        dataSource = HomeTableViewDataSource(tabBarSceneDIProvider: diProvider, actions: actions)
    }
    
    private func setupNavigationView() {
        navigationView = diProvider.createNavigationView(on: navigationViewContainer)
    }
    
    private func setupCategoriesOverlayView() {
        categoriesOverlayView = .create(using: diProvider, on: view)
        isPresentedDidChange(in: categoriesOverlayView)
    }
    
    private func setupSubviewsDependencies() {
        OpaqueView.createViewModel(on: categoriesOverlayView.opaqueView, with: viewModel)
    }
    
    func removeObservers() {
        if let viewModel = viewModel {
            printIfDebug("Removed `HomeViewModel` observers.")
            viewModel.tableViewState.remove(observer: self)
            viewModel.presentedDisplayMedia.remove(observer: self)
        }
    }
}

// MARK: - HomeViewModelActions implementation

extension HomeViewController {
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        if case .display = HomeTableViewDataSource.Index(rawValue: indexPath.section) {
            return self.view.bounds.height * 0.76
        }
        return self.view.bounds.height * 0.19
    }
    
    func viewDidScroll(in scrollView: UIScrollView) {
        guard let translation = scrollView.panGestureRecognizer.translation(in: self.view) as CGPoint? else { return }
        self.view.animateUsingSpring(withDuration: 0.66,
                                     withDamping: 1.0,
                                     initialSpringVelocity: 1.0) {
            guard translation.y < 0 else {
                self.navigationViewTopConstraint.constant = 0.0
                self.navigationView.alpha = 1.0
                return self.view.layoutIfNeeded()
            }
            self.navigationViewTopConstraint.constant = -162.0
            self.navigationView.alpha = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func didSelectItem(at section: Int, of row: Int) {
        let section = viewModel.sections[section]
        let media = section.media[row]
        viewModel.dependencies.actions.presentMediaDetails(section, media)
    }
}

// MARK: - Closure bindings

extension HomeViewController {
    
    private func isPresentedDidChange(in categoriesOverlayView: CategoriesOverlayView) {
        categoriesOverlayView.viewModel.isPresentedDidChange = { [weak self] in
            categoriesOverlayView.viewModel.isPresented.value == true
                ? self?.tabBarController?.tabBar.isHidden(true)
                : self?.tabBarController?.tabBar.isHidden(false)
        }
    }
}

// MARK: - Observer bindings

extension HomeViewController {
    
    private func tableViewState(in viewModel: HomeViewModel) {
        viewModel.tableViewState.observe(on: self) { [weak self] _ in self?.setupDataSource() }
    }
    
    private func presentedDisplayMedia(in viewModel: HomeViewModel) {
        viewModel.presentedDisplayMedia.observe(on: self) { [weak self] _ in self?.setupSubviewsDependencies() }
    }
}
