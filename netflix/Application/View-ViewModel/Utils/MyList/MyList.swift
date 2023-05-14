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
    
    func createViewModel() -> MyListViewModel
}

// MARK: - MyList Type

final class MyList {
    static var shared: MyList = MyList()
    
    private(set) lazy var viewModel: MyListViewModel = createViewModel()
    
    private init() {}
}

// MARK: - ListProtocol Implementation

extension MyList: ListProtocol {
    fileprivate func createViewModel() -> MyListViewModel {
        return MyListViewModel()
    }
    
    func dataWillLoad() {
        if #available(iOS 13.0, *) {
            Task {
                await loadUsingAsyncAwait()
            }
            
            return
        }
        
        loadAsync()
    }
    
    fileprivate func loadUsingAsyncAwait() async {
        mainQueueDispatch { [weak self] in
            self?.viewModel.listWillLoad()
        }
    }
    
    fileprivate func loadAsync() {
        mainQueueDispatch { [weak self] in
            self?.viewModel.listWillLoad()
        }
    }
}
