//
//  ShowcaseTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var showcaseView: ShowcaseView! { get }
    var viewModel: ShowcaseTableViewCellViewModel! { get }
}

private typealias ViewProtocol = ViewOutput

// MARK: - ShowcaseTableViewCell Type

final class ShowcaseTableViewCell: UITableViewCell, ViewProtocol {
    private(set) var showcaseView: ShowcaseView!
    private(set) var viewModel: ShowcaseTableViewCellViewModel!
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
        let showcaseView = ShowcaseView(with: cell.viewModel)
        cell.showcaseView = showcaseView
        cell.contentView.addSubview(cell.showcaseView)
        cell.showcaseView.constraintToSuperview(cell.contentView)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showcaseView.removeFromSuperview()
    }
}
