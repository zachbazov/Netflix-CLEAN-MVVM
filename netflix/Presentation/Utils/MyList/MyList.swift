//
//  MyList.swift
//  netflix
//
//  Created by Zach Bazov on 14/11/2022.
//

import UIKit

// MARK: - MyList Type

final class MyList {
    
    // MARK: Properties
    
    let viewModel: MyListViewModel
    
    // MARK: Initializer
    
    init(with viewModel: HomeViewModel) {
        self.viewModel = MyListViewModel(with: viewModel)
        self.viewDidLoad()
    }
}

// MARK: - UI Setup

extension MyList {
    private func viewDidLoad() {
        setupObservers()
        viewModel.fetchList()
    }
}

// MARK: - Observers

extension MyList {
    private func setupObservers() {
        viewModel.list.observe(on: self) { [weak self] _ in
            self?.viewModel.listDidReload()
        }
    }
    
    func removeObservers() {
        if let list = viewModel.list as Observable<Set<Media>>? {
            printIfDebug(.success, "Removed `MyList` observers.")
            list.remove(observer: self)
        }
    }
}
