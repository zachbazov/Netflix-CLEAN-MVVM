//
//  DetailInfoTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var infoView: DetailInfoView! { get }
    
    func viewDidConfigure()
}

private typealias ViewProtocol = ViewOutput

// MARK: - DetailInfoTableViewCell Type

final class DetailInfoTableViewCell: UITableViewCell {
    fileprivate var infoView: DetailInfoView!
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
            for: indexPath) as? DetailInfoTableViewCell else {
            fatalError()
        }
        let viewModel = DetailInfoViewViewModel(with: viewModel)
        cell.infoView = DetailInfoView(on: cell.contentView, with: viewModel)
        cell.contentView.addSubview(cell.infoView)
        cell.infoView.constraintToSuperview(cell.contentView)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewProtocol Implementation

extension DetailInfoTableViewCell: ViewProtocol {
    fileprivate func viewDidConfigure() {
        backgroundColor = .black
        selectionStyle = .none
    }
}
