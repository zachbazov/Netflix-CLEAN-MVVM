//
//  NavigationOverlayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    var titleLabel: UILabel { get }
    
    func viewDidConfigure(with viewModel: NavigationOverlayCollectionViewCellViewModel)
}

// MARK: - NavigationOverlayTableViewCell Type

final class NavigationOverlayTableViewCell: UITableViewCell {
    fileprivate lazy var titleLabel = createLabel()
    /// Create and dequeue a navigation overlay table view cell.
    /// - Parameters:
    ///   - tableView: Corresponding table view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A navigation overlay table view cell.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: NavigationOverlayViewModel) -> NavigationOverlayTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NavigationOverlayTableViewCell.reuseIdentifier,
            for: indexPath) as? NavigationOverlayTableViewCell else {
            fatalError()
        }
        let model = viewModel.items.value[indexPath.row]
        let viewModel = NavigationOverlayCollectionViewCellViewModel(title: model.stringValue)
        cell.viewDidDeploySubviews()
        cell.viewDidConfigure(with: viewModel)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

// MARK: - ViewLifecycleBehavior Implementation

extension NavigationOverlayTableViewCell: ViewLifecycleBehavior {
    func viewDidDeploySubviews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
}

// MARK: - ViewProtocol Implementation

extension NavigationOverlayTableViewCell: ViewProtocol {
    fileprivate func createLabel() -> UILabel {
        let label = UILabel(frame: .init(x: .zero, y: .zero,
                                         width: UIScreen.main.bounds.width, height: 44.0))
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        addSubview(label)
        return label
    }
    
    fileprivate func viewDidConfigure(with viewModel: NavigationOverlayCollectionViewCellViewModel) {
        titleLabel.text = viewModel.title
    }
}
