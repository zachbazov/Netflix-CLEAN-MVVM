//
//  DetailDescriptionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - DetailDescriptionTableViewCell Type

final class DetailDescriptionTableViewCell: UITableViewCell {
    /// Create a detail description table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A detail description table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: DetailViewModel) -> DetailDescriptionTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DetailDescriptionTableViewCell.reuseIdentifier,
            for: indexPath) as? DetailDescriptionTableViewCell
        else { fatalError() }
        
        cell.createDescription(with: viewModel)
        
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

extension DetailDescriptionTableViewCell {
    private func createDescription(with viewModel: DetailViewModel) {
        let viewModel = DetailDescriptionViewViewModel(with: viewModel.media)
        let view = DetailDescriptionView(on: contentView, with: viewModel)
        
        view.addToHierarchy(on: contentView)
            .constraintToSuperview(contentView)
    }
}
