//
//  NavigationOverlayView.swift
//  netflix
//
//  Created by Zach Bazov on 20/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var dataSource: NavigationOverlayTableViewDataSource? { get }
    var opaqueView: OpaqueView? { get }
    var footerView: NavigationOverlayFooterView? { get }
    var tableView: UITableView { get }
    
    func createDataSource() -> NavigationOverlayTableViewDataSource
    func createTableView(with dataSource: NavigationOverlayTableViewDataSource?) -> UITableView
    func setupViewModel(with viewModel: HomeViewModel) -> NavigationOverlayViewModel
    func createOpaqueView() -> OpaqueView
    func createFooterView() -> NavigationOverlayFooterView?
    
    func presentOverlayIfNeeded(_ condition: Bool)
}

// MARK: - NavigationOverlayView Type

final class NavigationOverlayView: View<NavigationOverlayViewModel> {
    private(set) lazy var dataSource: NavigationOverlayTableViewDataSource? = createDataSource()
    private(set) lazy var tableView: UITableView = createTableView(with: dataSource)
    private(set) lazy var opaqueView: OpaqueView? = createOpaqueView()
    private(set) lazy var footerView: NavigationOverlayFooterView? = createFooterView()
    
    private let parent: UIView
    
    /// Create a navigation overlay view object.
    /// - Parameter viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: HomeViewModel) {
        self.parent = parent
        
        super.init(frame: parent.bounds)
        
        self.viewModel = setupViewModel(with: viewModel)
        
        self.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
        viewWillBindObservers()
    }
    
    override func viewHierarchyWillConfigure() {
        self.addToHierarchy(on: parent)
            .constraintToSuperview(parent)
        
        self.footerView?
            .addToHierarchy(on: parent)
        
        tableView
            .addToHierarchy(on: self)
            .constraintToSuperview(parent)
    }
    
    override func viewWillBindObservers() {
        viewModel?.isPresented.observe(on: self) { [weak self] presented in
            guard let self = self else { return }
                
            self.viewShouldAppear(presented)
        }
        
        viewModel?.state.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            
            self.viewModel?.stateDidChange(state)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.isPresented.remove(observer: self)
        viewModel.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillAnimateAppearance() {
        guard let controller = viewModel.coordinator.viewController else { return }
        
        parent.isHidden(false)
        
        UIView.animate(
            withDuration: 0.5,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.alpha = 1.0
                self.tableView.alpha = 1.0
                self.footerView?.alpha = 1.0
                
                controller.tabBarController?.tabBar.alpha = .zero
            })
    }
    
    override func viewWillAnimateDisappearance() {
        guard let controller = viewModel.coordinator.viewController else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.alpha = .zero
                self.tableView.alpha = .zero
                self.footerView?.alpha = .zero
                
                controller.tabBarController?.tabBar.alpha = 1.0
            },
            completion: { [weak self] done in
                guard let self = self else { return }
                
                self.parent.isHidden(true)
            })
    }
    
    override func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        tableView.removeFromSuperview()
        footerView?.removeFromSuperview()
        
        viewModel = nil
        
        removeFromSuperview()
    }
}

// MARK: - ViewProtocol Implementation

extension NavigationOverlayView: ViewProtocol {
    fileprivate func createDataSource() -> NavigationOverlayTableViewDataSource {
        return NavigationOverlayTableViewDataSource(with: viewModel)
    }
    
    fileprivate func createTableView(with dataSource: NavigationOverlayTableViewDataSource?) -> UITableView {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(class: NavigationOverlayTableViewCell.self)
        tableView.backgroundColor = .clear
        tableView.backgroundView = opaqueView
        tableView.contentInset = .init(top: 32.0, left: .zero, bottom: .zero, right: .zero)
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        return tableView
    }
    
    fileprivate func setupViewModel(with viewModel: HomeViewModel) -> NavigationOverlayViewModel {
        return NavigationOverlayViewModel(with: viewModel)
    }
    
    fileprivate func createOpaqueView() -> OpaqueView {
        return OpaqueView(frame: .screenSize).apply()
    }
    
    fileprivate func createFooterView() -> NavigationOverlayFooterView? {
        guard let controller = viewModel.coordinator.viewController else { return nil }
        return NavigationOverlayFooterView(parent: controller.view, viewModel: viewModel)
    }
    
    func presentOverlayIfNeeded(_ condition: Bool) {
        guard condition else { return }
        
        viewShouldAppear(condition)
        viewModel?.stateWillChange(.main)
    }
}

// MARK: - Category Type

extension NavigationOverlayView {
    /// Category aka Media's genres representation type.
    typealias Category = MediaTableViewDataSource.Index
}

// MARK: - NavigationOverlayView.Category to Section Conversion

extension NavigationOverlayView.Category {
    func toSection() -> Section {
        guard let controller = Application.app.coordinator.tabCoordinator?.viewController?.homeViewController,
              let viewModel = controller.viewModel
        else { return .vacantValue }
        
        switch self {
        case .newRelease: return viewModel.section(at: .newRelease)
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
        default: return viewModel.section(at: .rated)
        }
    }
}
