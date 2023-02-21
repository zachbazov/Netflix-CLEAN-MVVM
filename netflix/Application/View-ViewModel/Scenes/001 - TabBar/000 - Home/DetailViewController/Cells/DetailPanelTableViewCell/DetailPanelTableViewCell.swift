//
//  DetailPanelTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewOutput {
    var panelView: DetailPanelView! { get }
    
    func viewDidConfigure()
}

private typealias ViewProtocol = ViewOutput

// MARK: - DetailPanelTableViewCell Type

final class DetailPanelTableViewCell: UITableViewCell {
    private(set) var panelView: DetailPanelView!
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
            for: indexPath) as? DetailPanelTableViewCell else {
            fatalError()
        }
        cell.panelView = DetailPanelView(on: cell.contentView, with: viewModel)
        cell.contentView.addSubview(cell.panelView)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewProtocol Implementation

extension DetailPanelTableViewCell: ViewProtocol {
    fileprivate func viewDidConfigure() {
        backgroundColor = .black
        selectionStyle = .none
    }
}
