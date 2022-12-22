//
//  DisplayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

final class DisplayTableViewCell: UITableViewCell {
    let displayView: DisplayView
    private let viewModel: DisplayTableViewCellViewModel
    /// Create a display table view cell.
    /// - Parameters:
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    init(for indexPath: IndexPath, with viewModel: HomeViewModel) {
        self.viewModel = DisplayTableViewCellViewModel(with: viewModel)
        let displayView = DisplayView(with: self.viewModel)
        self.displayView = displayView
        super.init(style: .default, reuseIdentifier: DisplayTableViewCell.reuseIdentifier)
        self.contentView.addSubview(self.displayView)
        self.displayView.constraintToSuperview(self.contentView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension DisplayTableViewCell {
    func terminate() {
        storeDisplayCacheBeforeReallocation()
    }
    
    private func storeDisplayCacheBeforeReallocation() {
        let tabViewModel = Application.current.rootCoordinator.tabViewModel
        let homeViewModel = viewModel.coordinator!.viewController!.viewModel!
        tabViewModel?.latestDisplayCache = homeViewModel.displayMediaCache
    }
}
