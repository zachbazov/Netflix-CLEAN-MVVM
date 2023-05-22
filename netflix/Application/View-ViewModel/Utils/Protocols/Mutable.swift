//
//  Mutable.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - Mutable Type

protocol Mutable {
    associatedtype Cell where Cell: UICollectionViewCell
    func sort(_ sortOptions: MediaHybridCell<Cell>.SortOptions, sliceBy length: Int) -> Section?
    func slice(_ length: Int) -> Section?
}
