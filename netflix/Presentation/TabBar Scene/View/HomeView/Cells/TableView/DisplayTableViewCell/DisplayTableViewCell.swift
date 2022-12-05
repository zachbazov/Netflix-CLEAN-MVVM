//
//  DisplayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

// MARK: - DisplayTableViewCellDependencies protocol

protocol DisplayTableViewCellDependencies {
    func createDisplayTableViewCellViewModel() -> DisplayTableViewCellViewModel
}

// MARK: - DisplayTableViewCell class

final class DisplayTableViewCell: UITableViewCell {
    
    let displayView: DisplayView
    
    init(for indexPath: IndexPath, with viewModel: HomeViewModel) {
        let viewModel = DisplayTableViewCellViewModel(with: viewModel)
        let displayView = DisplayView(with: viewModel)
        self.displayView = displayView
        super.init(style: .default, reuseIdentifier: DisplayTableViewCell.reuseIdentifier)
        self.contentView.addSubview(self.displayView)
        self.displayView.constraintToSuperview(self.contentView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
