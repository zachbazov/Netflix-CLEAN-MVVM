//
//  NavigationOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var dataSource: NavigationOverlayTableViewDataSource! { get }
    var opaqueView: OpaqueView? { get }
    var footerView: NavigationOverlayFooterView! { get }
    var tabBar: UITabBar! { get }
    var tableView: UITableView { get }
    
    func createTableView() -> UITableView
}

// MARK: - NavigationOverlayView Type

final class NavigationOverlayView: View<NavigationOverlayViewModel> {
    var dataSource: NavigationOverlayTableViewDataSource!
    var opaqueView: OpaqueView?
    var footerView: NavigationOverlayFooterView!
    var tabBar: UITabBar!
    private(set) lazy var tableView: UITableView = createTableView()
    
    /// Create a navigation overlay view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        let rect = CGRect(x: UIScreen.main.bounds.width, y: .zero,
                          width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        super.init(frame: rect)
        self.alpha = .zero
        
        self.tabBar = viewModel.coordinator!.viewController!.tabBarController!.tabBar
        self.viewModel = NavigationOverlayViewModel(with: viewModel)
        self.dataSource = NavigationOverlayTableViewDataSource(with: self.viewModel)
        self.opaqueView = OpaqueView(frame: UIScreen.main.bounds)
        let parent = viewModel.coordinator!.viewController!.view!
        self.footerView = NavigationOverlayFooterView(parent: parent, viewModel: self.viewModel)
        
        parent.addSubview(self)
        parent.addSubview(self.footerView)
        self.addSubview(self.tableView)
        
        // Updates root coordinator's `categoriesOverlayView` property.
        viewModel.coordinator?.viewController?.navigationOverlayView = self
        
        self.viewDidBindObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        viewDidUnbindObservers()
        tableView.removeFromSuperview()
        footerView.removeFromSuperview()
        removeFromSuperview()
    }
    
    override func viewDidBindObservers() {
        viewModel.isPresented.observe(on: self) { [weak self] _ in
            self?.opaqueView?.viewDidUpdate()
            self?.viewModel.isPresentedDidChange()
            self?.animatePresentation()
        }
        
        viewModel.items.observe(on: self) { [weak self] _ in self?.viewModel.dataSourceDidChange() }
    }
    
    override func viewDidUnbindObservers() {
        printIfDebug(.success, "Removed `NavigationOverlayView` observers.")
        viewModel.isPresented.remove(observer: self)
        viewModel.items.remove(observer: self)
    }
}

// MARK: - ViewProtocol Implementation

extension NavigationOverlayView: ViewProtocol {
    fileprivate func createTableView() -> UITableView {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(class: NavigationOverlayTableViewCell.self)
        tableView.backgroundView = opaqueView
        return tableView
    }
    
    /// Animate the presentation of the view.
    fileprivate func animatePresentation() {
        animateUsingSpring(
            withDuration: 0.5,
            withDamping: 1.0,
            initialSpringVelocity: 0.5,
            animations: { [weak self] in
                guard let self = self else { return }
                self.transform = self.viewModel.isPresented.value
                    ? CGAffineTransform(translationX: -self.bounds.size.width, y: .zero)
                    : .identity
                self.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.tableView.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.footerView.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.tabBar.alpha = self.viewModel.isPresented.value ? 0.0 : 1.0
            },
            completion: { [weak self] done in
                guard let self = self else { return }
                /// In-case the overlay has been closed and animation is done.
                if !self.viewModel.isPresented.value && done {
                    self.tableView.delegate = nil
                    self.tableView.dataSource = nil
                }
            })
    }
}

// MARK: - Category Type

extension NavigationOverlayView {
    /// Genres representation type.
    enum Category: Int, CaseIterable {
        case newRelease
        case home
        case myList
        case action
        case sciFi
        case crime
        case thriller
        case adventure
        case comedy
        case drama
        case horror
        case anime
        case familyNchildren
        case documentary
    }
}

// MARK: - Valuable Implementation

extension NavigationOverlayView.Category: Valuable {
    var stringValue: String {
        switch self {
        case .newRelease: return "New Release"
        case .home: return Localization.TabBar.Home.Navigation.Overlay().home
        case .myList: return Localization.TabBar.Home.Navigation.Overlay().myList
        case .action: return Localization.TabBar.Home.Navigation.Overlay().action
        case .sciFi: return Localization.TabBar.Home.Navigation.Overlay().sciFi
        case .crime: return Localization.TabBar.Home.Navigation.Overlay().crime
        case .thriller: return Localization.TabBar.Home.Navigation.Overlay().thriller
        case .adventure: return Localization.TabBar.Home.Navigation.Overlay().adventure
        case .comedy: return Localization.TabBar.Home.Navigation.Overlay().comedy
        case .drama: return Localization.TabBar.Home.Navigation.Overlay().drama
        case .horror: return Localization.TabBar.Home.Navigation.Overlay().horror
        case .anime: return Localization.TabBar.Home.Navigation.Overlay().anime
        case .familyNchildren: return Localization.TabBar.Home.Navigation.Overlay().familyNchildren
        case .documentary: return Localization.TabBar.Home.Navigation.Overlay().documentary
        }
    }
}

// MARK: - NavigationOverlayView.Category - Section Conversion

extension NavigationOverlayView.Category {
    func toSection(with viewModel: HomeViewModel) -> Section {
        switch self {
        case .newRelease: return viewModel.section(at: .newRelease)
        case .home: return viewModel.section(at: .resumable)
        case .myList: return viewModel.section(at: .myList)
        case .action: return viewModel.section(at: .action)
        case .sciFi: return viewModel.section(at: .sciFi)
        case .crime: return viewModel.section(at: .crime)
        case .thriller: return viewModel.section(at: .thriller)
        case .adventure: return viewModel.section(at: .adventure)
        case .comedy: return viewModel.section(at: .comedy)
        case .drama: return viewModel.section(at: .drama)
        case .horror: return viewModel.section(at: .horror)
        case .anime: return viewModel.section(at: .anime)
        case .familyNchildren: return viewModel.section(at: .familyNchildren)
        case .documentary: return viewModel.section(at: .documentary)
        }
    }
}
