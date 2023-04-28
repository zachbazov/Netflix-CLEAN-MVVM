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
    
    var gradientView: UIView!
    
    /// Create a navigation overlay view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        super.init(frame: .screenSize)
        self.alpha = .zero
        
        self.tabBar = viewModel.coordinator!.viewController!.tabBarController!.tabBar
        self.viewModel = NavigationOverlayViewModel(with: viewModel)
        self.dataSource = NavigationOverlayTableViewDataSource(with: self.viewModel)
        self.opaqueView = OpaqueView(frame: UIScreen.main.bounds)
        let parent = viewModel.coordinator!.viewController!.view!
        self.footerView = NavigationOverlayFooterView(parent: parent, viewModel: self.viewModel)
        self.gradientView = .init(frame: CGRect(x: .zero, y: UIScreen.main.bounds.height - 192.0, width: UIScreen.main.bounds.width, height: 192.0))
        self.gradientView.addGradientLayer(colors: [.clear, .hexColor("#050505")], locations: [0.0, 0.85])
        
        parent.addSubview(self)
        parent.addSubview(self.footerView)
        self.addSubview(self.tableView)
        self.addSubview(self.gradientView)
        
        self.viewDidBindObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        viewDidUnbindObservers()
        tableView.removeFromSuperview()
        footerView.removeFromSuperview()
        removeFromSuperview()
    }
    
    override func viewDidBindObservers() {
        viewModel?.isPresented.observe(on: self) { [weak self] isPresented in
            self?.opaqueView?.viewDidUpdate()
            self?.viewWillAnimateAppearance()
            self?.removeBlurness()
        }
        
        viewModel?.state.observe(on: self) { [weak self] state in
            self?.dataSourceDidChange()
        }
    }
    
    override func viewDidUnbindObservers() {
        guard viewModel.isNotNil else { return }
        
        viewModel?.isPresented.remove(observer: self)
        viewModel?.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillAnimateAppearance() {
        UIView.animate(
            withDuration: 0.5,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                self.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.tableView.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.footerView.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.tabBar.alpha = self.viewModel.isPresented.value ? 0.0 : 1.0
            })
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
        tableView.backgroundColor = .clear
        tableView.backgroundView = opaqueView
        return tableView
    }
    
    /// Release data source changes and center the content.
    func dataSourceDidChange() {
        self.viewModel?.itemsDidChange()
        
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        
        tableView.reloadData()
        
        tableView.contentInset = .init(top: 32.0, left: .zero, bottom: .zero, right: .zero)
        
        opaqueView?.add()
    }
    
    func removeBlurness() {
        guard !viewModel.isPresented.value else { return }
        
        opaqueView?.remove()
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
        case .home: return Localization.TabBar.Home.SegmentControl.Overlay().home
        case .myList: return Localization.TabBar.Home.SegmentControl.Overlay().myList
        case .action: return Localization.TabBar.Home.SegmentControl.Overlay().action
        case .sciFi: return Localization.TabBar.Home.SegmentControl.Overlay().sciFi
        case .crime: return Localization.TabBar.Home.SegmentControl.Overlay().crime
        case .thriller: return Localization.TabBar.Home.SegmentControl.Overlay().thriller
        case .adventure: return Localization.TabBar.Home.SegmentControl.Overlay().adventure
        case .comedy: return Localization.TabBar.Home.SegmentControl.Overlay().comedy
        case .drama: return Localization.TabBar.Home.SegmentControl.Overlay().drama
        case .horror: return Localization.TabBar.Home.SegmentControl.Overlay().horror
        case .anime: return Localization.TabBar.Home.SegmentControl.Overlay().anime
        case .familyNchildren: return Localization.TabBar.Home.SegmentControl.Overlay().familyNchildren
        case .documentary: return Localization.TabBar.Home.SegmentControl.Overlay().documentary
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
