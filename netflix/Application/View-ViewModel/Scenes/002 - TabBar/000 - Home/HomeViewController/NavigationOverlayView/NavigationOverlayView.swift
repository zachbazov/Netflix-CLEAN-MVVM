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
}

// MARK: - NavigationOverlayView Type

final class NavigationOverlayView: View<NavigationOverlayViewModel> {
    private(set) lazy var dataSource: NavigationOverlayTableViewDataSource? = createDataSource()
    private(set) lazy var tableView: UITableView = createTableView(with: dataSource)
    private(set) lazy var opaqueView: OpaqueView? = createOpaqueView()
    private(set) lazy var footerView: NavigationOverlayFooterView? = createFooterView()
    
    var gradientView: UIView?
    
    /// Create a navigation overlay view object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: HomeViewModel) {
        super.init(frame: .screenSize)
        self.alpha = .zero
        
        self.viewModel = setupViewModel(with: viewModel)
        
        let rect = CGRect(x: .zero, y: CGRect.screenSize.height - 192.0, width: CGRect.screenSize.width, height: 192.0)
        self.gradientView = .init(frame: rect)
        self.gradientView?.addGradientLayer(colors: [.clear, .hexColor("#050505")], locations: [0.0, 0.85])
        
        guard let controller = viewModel.coordinator?.viewController else { return }
        controller.view.addSubview(self)
        controller.view.addSubview(self.footerView!)
        
        self.addSubview(self.tableView)
        self.addSubview(self.gradientView!)
        
        self.viewDidBindObservers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        print("deinit \(Self.self)")
        viewDidUnbindObservers()
        tableView.removeFromSuperview()
        footerView?.removeFromSuperview()
        removeFromSuperview()
    }
    
    override func viewDidBindObservers() {
        viewModel?.isPresented.observe(on: self) { [weak self] _ in
            self?.viewWillAnimateAppearance()
        }
        
        viewModel?.state.observe(on: self) { [weak self] _ in
            self?.viewModel?.updateItems()
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidUnbindObservers() {
        guard viewModel.isNotNil else { return }
        
        viewModel?.isPresented.remove(observer: self)
        viewModel?.state.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillAnimateAppearance() {
        guard let controller = viewModel.coordinator.viewController else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: .zero,
            options: .curveEaseInOut,
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.tableView.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                self.footerView?.alpha = self.viewModel.isPresented.value ? 1.0 : 0.0
                
                controller.tabBarController?.tabBar.alpha = self.viewModel.isPresented.value ? 0.0 : 1.0
            })
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
}

// MARK: - Category Type

extension NavigationOverlayView {
    /// Category aka Media's genres representation type.
    typealias Category = HomeTableViewDataSource.Index
}

// MARK: - NavigationOverlayView.Category to Section Conversion

extension NavigationOverlayView.Category {
    func toSection() -> Section {
        guard let controller = Application.app.coordinator.tabCoordinator.home.viewControllers.first as? HomeViewController,
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
