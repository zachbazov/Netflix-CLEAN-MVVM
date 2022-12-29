//
//  DetailNavigationTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailNavigationTableViewCell Type

final class DetailNavigationTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    private var navigationView: DetailNavigationView!
    
    // MARK: Initializer
    
    /// Create a detail navigation table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A detail navigation table view cell.
    static func create(on tableView: UITableView, for indexPath: IndexPath, with viewModel: DetailViewModel) -> DetailNavigationTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailNavigationTableViewCell.reuseIdentifier, for: indexPath) as? DetailNavigationTableViewCell else {
            fatalError()
        }
        cell.navigationView = DetailNavigationView(on: cell.contentView, with: viewModel)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension DetailNavigationTableViewCell {
    private func viewDidConfigure() {
        backgroundColor = .black
        selectionStyle = .none
    }
}
