//
//  NewsTableViewDataSource.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import UIKit.UITableView

final class NewsTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: NewsViewModel
    private let numberOfSections: Int = 1
    
    init(with viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return NewsTableViewCell.create(in: tableView, for: indexPath, with: viewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let x = viewModel.coordinator!.viewController!.tableViewContainer.bounds.size.height
        if indexPath.row % 1 == 0 {
            return x - (x - 426.0 - 34.0)
        } else {
            return x - 426.0 - 34.0
        }
    }
}
