//
//  TableViewHeaderFooterView.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - TableViewHeaderFooterView Type

final class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    // MARK: Properties
    
    private var viewModel: TableViewHeaderFooterViewViewModel!
    private lazy var titleLabel = createLabel()
    
    // MARK: Initializer
    
    /// Create a table view header view object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - section: The represented section for the header.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A table view header footer view.
    static func create(on tableView: UITableView, for section: Int, with viewModel: HomeViewModel) -> TableViewHeaderFooterView {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? TableViewHeaderFooterView else {
            fatalError()
        }
        cell.viewModel = TableViewHeaderFooterViewViewModel()
        cell.viewDidConfigure(at: section, with: viewModel)
        return cell
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension TableViewHeaderFooterView {
    private func createLabel() -> UILabel {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 17.0, weight: .heavy)
        label.font = font
        label.textColor = .white
        contentView.addSubview(label)
        label.constraintBottom(toParent: self, withLeadingAnchor: 8.0)
        return label
    }
    
    private func viewDidConfigure(at index: Int, with homeViewModel: HomeViewModel) {
        backgroundView = .init()
        backgroundView?.backgroundColor = .black
        
        titleLabel.text = viewModel.title(homeViewModel.sections, forHeaderAt: index)
    }
}
