//
//  ShowcaseTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var showcaseView: ShowcaseView? { get }
    var viewModel: ShowcaseTableViewCellViewModel? { get }
    
    func createViewModel() -> ShowcaseTableViewCellViewModel?
    func createShowcaseView()
}

// MARK: - ShowcaseTableViewCell Type

final class ShowcaseTableViewCell: UITableViewCell {
    fileprivate lazy var viewModel: ShowcaseTableViewCellViewModel? = createViewModel()
    fileprivate var showcaseView: ShowcaseView?
    
    /// Create a display table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A display table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> ShowcaseTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ShowcaseTableViewCell.reuseIdentifier,
            for: indexPath) as? ShowcaseTableViewCell else {
            fatalError()
        }
        
        cell.viewDidLoad()
        
        return cell
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        showcaseView?.viewWillDeallocate()
        
        viewWillDeallocate()
    }
    
    override func prepareForReuse() {
        showcaseView?.viewWillDeallocate()
        
        super.prepareForReuse()
        
        showcaseView?.setDarkBottomGradient()
    }
    
    func viewDidLoad() {
        viewWillConfigure()
        viewWillDeploySubviews()
        viewHierarchyWillConfigure()
    }
    
    func viewWillDeploySubviews() {
        createShowcaseView()
    }
    
    func viewHierarchyWillConfigure() {
        showcaseView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewWillConfigure() {
        setBackgroundColor(.clear)
    }
    
    func viewWillDeallocate() {
        showcaseView = nil
        
        viewModel = nil
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension ShowcaseTableViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension ShowcaseTableViewCell: ViewProtocol {
    fileprivate func createViewModel() -> ShowcaseTableViewCellViewModel? {
        guard let controller = Application.app.coordinator.tabCoordinator.viewController?.homeViewController else { return nil }
        
        return ShowcaseTableViewCellViewModel(with: controller.viewModel)
    }
    
    fileprivate func createShowcaseView() {
        showcaseView = ShowcaseView(on: contentView, with: viewModel)
    }
}
