//
//  DetailInfoTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailInfoTableViewCell Type

final class DetailInfoTableViewCell: UITableViewCell {
    /// Create a detail info table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cel on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A detail info table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: DetailViewModel) -> DetailInfoTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DetailInfoTableViewCell.reuseIdentifier,
            for: indexPath) as? DetailInfoTableViewCell
        else { fatalError() }
        
        cell.createInfo(with: viewModel)
        
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setBackgroundColor(.black)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Private Presentation Implementation

extension DetailInfoTableViewCell {
    private func createInfo(with viewModel: DetailViewModel) {
        let viewModel = DetailInfoViewViewModel(with: viewModel)
        let view = DetailInfoView(on: contentView, with: viewModel)
        
        view.addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
}
