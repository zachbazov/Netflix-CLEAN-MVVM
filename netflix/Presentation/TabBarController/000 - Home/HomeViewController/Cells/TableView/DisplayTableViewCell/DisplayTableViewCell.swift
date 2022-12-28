//
//  DisplayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

final class DisplayTableViewCell: UITableViewCell {
    private(set) var displayView: DisplayView!
    private(set) var viewModel: DisplayTableViewCellViewModel!
    /// Create a display table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A display table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> DisplayTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DisplayTableViewCell.reuseIdentifier,
            for: indexPath) as? DisplayTableViewCell else {
            fatalError()
        }
        cell.viewModel = DisplayTableViewCellViewModel(with: viewModel)
        let displayView = DisplayView(with: cell.viewModel)
        cell.displayView = displayView
        cell.contentView.addSubview(cell.displayView)
        cell.displayView.constraintToSuperview(cell.contentView)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        displayView.removeFromSuperview()
    }
}
