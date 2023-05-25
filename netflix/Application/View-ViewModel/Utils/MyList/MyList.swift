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
            loadUsingAsyncAwait()
            
            return
        }
        
        loadAsync()
    }
    
    fileprivate func loadUsingAsyncAwait() {
        Task {
            await viewModel.listWillLoad()
        }
    }
    
    fileprivate func loadAsync() {
        viewModel.listWillLoad()
    }
}
