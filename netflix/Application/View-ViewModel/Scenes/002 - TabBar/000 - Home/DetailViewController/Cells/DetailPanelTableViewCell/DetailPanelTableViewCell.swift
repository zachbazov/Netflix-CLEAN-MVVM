//
//  DetailPanelTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailPanelTableViewCell Type

final class DetailPanelTableViewCell: UITableViewCell {
    /// Create a detail panel table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A detail panel table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: DetailViewModel) -> DetailPanelTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DetailPanelTableViewCell.reuseIdentifier,
            for: indexPath) as? DetailPanelTableViewCell
        else { fatalError() }
        
        cell.createPanelView(with: viewModel)
        
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setBackgroundColor(.black)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Private Presentation Logic

extension DetailPanelTableViewCell {
    private func createPanelView(with viewModel: DetailViewModel) {
        let panelView = DetailPanelView(on: contentView, with: viewModel)
        panelView.addToHierarchy(on: contentView)
    }
}
