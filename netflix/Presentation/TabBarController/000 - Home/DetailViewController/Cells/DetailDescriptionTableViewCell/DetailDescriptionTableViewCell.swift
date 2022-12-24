//
//  DetailDescriptionTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

final class DetailDescriptionTableViewCell: UITableViewCell {
    private var descriptionView: DetailDescriptionView!
    /// Create a detail description table view cell object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A detail description table view cell.
    static func create(on tableView: UITableView, for indexPath: IndexPath, with viewModel: DetailViewModel) -> DetailDescriptionTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailDescriptionTableViewCell.reuseIdentifier, for: indexPath) as? DetailDescriptionTableViewCell else {
            fatalError()
        }
        if cell.descriptionView == nil {
            let viewModel = DetailDescriptionViewViewModel(with: viewModel.media)
            cell.descriptionView = DetailDescriptionView(on: cell.contentView, with: viewModel)
            cell.contentView.addSubview(cell.descriptionView)
            cell.descriptionView.constraintToSuperview(cell.contentView)
        }
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension DetailDescriptionTableViewCell {
    private func viewDidConfigure() {
        backgroundColor = .black
        selectionStyle = .none
    }
}
