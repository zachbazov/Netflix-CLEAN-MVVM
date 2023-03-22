//
//  MyList.swift
//  netflix
//
//  Created by Zach Bazov on 14/11/2022.
//

import UIKit

// MARK: - ListProtocol Type

private protocol ListOutput {
    var viewModel: MyListViewModel { get }
    
    func viewDidLoad()
    func viewDidBindObservers()
    func viewDidUnbindObservers()
}

private typealias ListProtocol = ListOutput

// MARK: - MyList Type

final class MyList {
    let viewModel: MyListViewModel
    
    init(with viewModel: HomeViewModel) {
        self.viewModel = MyListViewModel(with: viewModel)
        self.viewDidLoad()
        self.viewDidBindObservers()
    }
}

// MARK: - ListProtocol Implementation

extension MyList: ListProtocol {
    fileprivate func viewDidLoad() {
        viewModel.fetchList()
    }
    
    func viewDidBindObservers() {
//        viewModel.list.observe(on: self) { [weak self] _ in
//            self?.viewModel.updateView()
//        }
    }
    
    func viewDidUnbindObservers() {
        if let list = viewModel.list as Observable<Set<Media>>? {
            printIfDebug(.success, "Removed `MyList` observers.")
            list.remove(observer: self)
        }
    }
}
