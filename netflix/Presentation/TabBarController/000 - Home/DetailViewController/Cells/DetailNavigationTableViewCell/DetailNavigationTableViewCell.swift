//
//  DetailNavigationTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import UIKit

final class DetailNavigationTableViewCell: UITableViewCell {
    var navigationView: DetailNavigationView!
    /// Create a navigation table view cell object.
    /// - Parameter viewModel: Coordinating view model.
    init(with viewModel: DetailViewModel) {
        super.init(style: .default, reuseIdentifier: DetailNavigationTableViewCell.reuseIdentifier)
        self.navigationView = DetailNavigationView(on: self.contentView, with: viewModel)
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        navigationView = nil
    }
}

extension DetailNavigationTableViewCell {
    private func viewDidConfigure() {
        backgroundColor = .black
        selectionStyle = .none
    }
}
