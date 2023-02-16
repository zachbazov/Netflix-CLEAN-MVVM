//
//  TableViewHeaderFooterViewViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 15/11/2022.
//

import Foundation

// MARK: - TableViewHeaderFooterViewViewModel Type

struct TableViewHeaderFooterViewViewModel {
    func title(_ sections: [Section], forHeaderAt index: Int) -> String {
        return String(describing: sections[index].title)
    }
}
