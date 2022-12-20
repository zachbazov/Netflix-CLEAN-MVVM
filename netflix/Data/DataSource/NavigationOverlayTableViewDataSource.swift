//
//  NavigationOverlayTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

final class NavigationOverlayTableViewDataSource: NSObject,
                                                  UITableViewDelegate,
                                                  UITableViewDataSource {
    enum State: Int {
        case none
        case mainMenu
        case categories
    }
    
    private weak var viewModel: NavigationOverlayViewModel!
    
    init(with viewModel: NavigationOverlayViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return NavigationOverlayTableViewCell(on: tableView,
                                              for: indexPath,
                                              with: viewModel.items.value)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.isPresented.value = false
        viewModel.didSelectRow(at: indexPath)
        if case .none? = State(rawValue: indexPath.section) {
            
        }
    }
}
