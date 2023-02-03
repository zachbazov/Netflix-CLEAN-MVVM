//
//  DetailCollectionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailCollectionTableViewCell Type

final class DetailCollectionTableViewCell: UITableViewCell {
    private(set) var detailCollectionView: DetailCollectionView!
    /// Create a detail collection table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A detail collection table view cell.
    static func create(on tableView: UITableView, for indexPath: IndexPath, with viewModel: DetailViewModel) -> DetailCollectionTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailCollectionTableViewCell.reuseIdentifier, for: indexPath) as? DetailCollectionTableViewCell else {
            fatalError()
        }
        cell.detailCollectionView = DetailCollectionView(on: cell.contentView, with: viewModel)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension DetailCollectionTableViewCell {
    private func viewDidConfigure() {
        backgroundColor = .black
        selectionStyle = .none
    }
}
