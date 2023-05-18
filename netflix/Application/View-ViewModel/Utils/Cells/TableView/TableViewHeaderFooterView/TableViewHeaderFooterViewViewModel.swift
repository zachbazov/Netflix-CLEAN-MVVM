//
//  TableViewHeaderFooterViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 15/11/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    func title(_ sections: [Section], forHeaderAt index: Int) -> String
}

// MARK: - TableViewHeaderFooterViewViewModel Type

struct TableViewHeaderFooterViewViewModel {
    func title(_ sections: [Section], forHeaderAt index: Int) -> String {
        return String(describing: sections[index].title)
    }
}

// MARK: - ViewModel Implementation

extension TableViewHeaderFooterViewViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension TableViewHeaderFooterViewViewModel: ViewModelProtocol {}
