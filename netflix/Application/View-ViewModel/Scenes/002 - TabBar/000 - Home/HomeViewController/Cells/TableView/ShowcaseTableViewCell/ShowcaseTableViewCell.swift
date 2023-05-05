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
    
    func createShowcaseView()
}

// MARK: - ShowcaseTableViewCell Type

final class ShowcaseTableViewCell: UITableViewCell {
    fileprivate var showcaseView: ShowcaseView?
    fileprivate var viewModel: ShowcaseTableViewCellViewModel?
    
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
        
        cell.viewModel = ShowcaseTableViewCellViewModel(with: viewModel)
        
        cell.viewDidLoad()
        
        return cell
    }
    
    deinit {
        print("deinit \(Self.self)")
        
        showcaseView?.gradient?.layer.removeFromSuperlayer()
        showcaseView?.gradient?.removeFromSuperview()
        showcaseView?.removeFromSuperview()
        showcaseView = nil
        
        viewModel?.coordinator = nil
        viewModel = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        showcaseView?.setDarkBottomGradient()
    }
    
    func viewDidLoad() {
        viewDidConfigure()
        viewDidDeploySubviews()
        viewHierarchyDidConfigure()
    }
    
    func viewDidDeploySubviews() {
        createShowcaseView()
    }
    
    func viewHierarchyDidConfigure() {
        showcaseView?
            .addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
    
    func viewDidConfigure() {
        setBackgroundColor(.clear)
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension ShowcaseTableViewCell: ViewLifecycleBehavior {}

// MARK: - ViewProtocol Implementation

extension ShowcaseTableViewCell: ViewProtocol {
    fileprivate func createShowcaseView() {
        showcaseView = ShowcaseView(on: contentView, with: viewModel)
    }
}
