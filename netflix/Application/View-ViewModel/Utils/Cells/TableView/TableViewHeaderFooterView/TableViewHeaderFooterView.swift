//
//  TableViewHeaderFooterView.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var titleLabel: UILabel { get }
    
    func createLabel() -> UILabel
}

// MARK: - TableViewHeaderFooterView Type

final class TableViewHeaderFooterView: TableViewHeaderView<TableViewHeaderFooterViewViewModel> {
    fileprivate lazy var titleLabel = createLabel()
    
    /// Create a table view header view object.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - section: The represented section for the header.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A table view header footer view.
    static func create(on tableView: UITableView,
                       for section: Int,
                       with viewModel: HomeViewModel) -> TableViewHeaderFooterView {
        guard let cell = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: reuseIdentifier) as? TableViewHeaderFooterView
        else { fatalError() }
        
        cell.viewModel = TableViewHeaderFooterViewViewModel()
        
        cell.viewWillConfigure(at: section, with: viewModel)
        
        return cell
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewWillConfigure(at index: Int, with homeViewModel: HomeViewModel) {
        backgroundView = .init()
        backgroundView?.setBackgroundColor(.clear)
        backgroundView?.constraintToSuperview(contentView)
        
        titleLabel.text = viewModel.title(homeViewModel.sections, forHeaderAt: index)
    }
}

// MARK: - ViewModelProtocol Implementation

extension TableViewHeaderFooterView: ViewModelProtocol {
    fileprivate func createLabel() -> UILabel {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.font = font
        label.textColor = .white
        label.numberOfLines = 0
        contentView.addSubview(label)
        label.constraintBottom(toParent: self, withLeadingAnchor: .zero)
        return label
    }
}
