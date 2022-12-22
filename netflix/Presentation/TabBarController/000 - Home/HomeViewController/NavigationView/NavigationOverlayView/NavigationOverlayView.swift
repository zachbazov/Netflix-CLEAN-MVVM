//
//  NavigationOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

final class NavigationOverlayView: UIView {
    let viewModel: NavigationOverlayViewModel
    let dataSource: NavigationOverlayTableViewDataSource
    let opaqueView = OpaqueView(frame: UIScreen.main.bounds)
    let footerView: NavigationOverlayFooterView
    let tabBar: UITabBar
    private(set) lazy var tableView: UITableView = createTableView()
    /// Create a navigation overlay view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        self.tabBar = viewModel.coordinator!.viewController!.tabBarController!.tabBar
        self.viewModel = NavigationOverlayViewModel(with: viewModel)
        self.dataSource = NavigationOverlayTableViewDataSource(with: self.viewModel)
        let parent = viewModel.coordinator!.viewController!.view!
        self.footerView = NavigationOverlayFooterView(parent: parent, viewModel: self.viewModel)
        
        super.init(frame: UIScreen.main.bounds)
        parent.addSubview(self)
        parent.addSubview(self.footerView)
        self.addSubview(self.tableView)
        /// Updates root coordinator's `categoriesOverlayView` property.
        viewModel.coordinator?.viewController?.navigationView?.navigationOverlayView = self
        
        self.setupObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        removeObservers()
        tableView.removeFromSuperview()
        footerView.removeFromSuperview()
    }
    
    private func createTableView() -> UITableView {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(class: NavigationOverlayTableViewCell.self)
        tableView.backgroundView = opaqueView
        return tableView
    }
}

extension NavigationOverlayView {
    private func setupObservers() {
        viewModel.isPresented.observe(on: self) { [weak self] _ in self?.viewModel.isPresentedDidChange() }
        viewModel.items.observe(on: self) { [weak self] _ in self?.viewModel.dataSourceDidChange() }
    }
    
    func removeObservers() {
        printIfDebug("Removed `NavigationOverlayView` observers.")
        viewModel.isPresented.remove(observer: self)
        viewModel.items.remove(observer: self)
    }
}

extension NavigationOverlayView {
    enum Category: Int, CaseIterable {
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

extension NavigationOverlayView.Category: Valuable {
    var stringValue: String {
        switch self {
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

extension NavigationOverlayView.Category {
    func toSection(with viewModel: HomeViewModel) -> Section {
        switch self {
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
