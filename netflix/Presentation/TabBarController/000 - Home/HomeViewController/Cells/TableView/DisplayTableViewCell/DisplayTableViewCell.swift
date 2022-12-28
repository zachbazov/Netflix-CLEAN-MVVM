//
//  DisplayTableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 15/09/2022.
//

import UIKit

final class DisplayTableViewCell: UITableViewCell {
    let displayView: DisplayView
    let viewModel: DisplayTableViewCellViewModel
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
//    func terminate() {
//        storeDisplayCacheBeforeReallocation()
//    }
//    
//    private func storeDisplayCacheBeforeReallocation() {
//        let tabViewModel = Application.current.rootCoordinator.tabViewModel
//        let homeViewModel = viewModel.coordinator!.viewController!.viewModel!
//        tabViewModel?.latestDisplayCache = homeViewModel.displayMediaCache
//    }
}

/*
 var displayView: DisplayView!
 private var viewModel: DisplayTableViewCellViewModel!
 /// Create a display table view cell.
 /// - Parameters:
 ///   - indexPath: The index path from the table view data source.
 ///   - viewModel: Coordinating view model.
 static func create(on tableView: UITableView, for indexPath: IndexPath, with viewModel: HomeViewModel) -> DisplayTableViewCell {
     guard let cell = tableView.dequeueReusableCell(withIdentifier: DisplayTableViewCell.reuseIdentifier, for: indexPath) as? DisplayTableViewCell else {
         fatalError()
     }
     if cell.displayView == nil {
         cell.viewModel = DisplayTableViewCellViewModel(with: viewModel)
         let displayView = DisplayView(with: cell.viewModel)
         cell.displayView = displayView
         cell.contentView.addSubview(cell.displayView)
         cell.displayView.constraintToSuperview(cell.contentView)
     } else {
         print("not nil")
     }
     return cell
 }
 
 override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
     super.init(style: style, reuseIdentifier: reuseIdentifier)
 }
 
 required init?(coder: NSCoder) {
     super.init(coder: coder)
 }
 */
