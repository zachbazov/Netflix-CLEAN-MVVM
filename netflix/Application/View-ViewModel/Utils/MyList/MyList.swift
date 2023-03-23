//
//  MyList.swift
//  netflix
//
//  Created by Zach Bazov on 14/11/2022.
//

import UIKit

// MARK: - ListProtocol Type

private protocol ListProtocol {
    var viewModel: MyListViewModel { get }
    
    func viewDidLoad()
}

// MARK: - MyList Type

final class MyList {
    let viewModel: MyListViewModel
    
    init(with viewModel: HomeViewModel) {
        self.viewModel = MyListViewModel(with: viewModel)
        self.viewDidLoad()
    }
}

// MARK: - ListProtocol Implementation

extension MyList: ListProtocol {
    fileprivate func viewDidLoad() {
        viewModel.fetchList()
    }
}
