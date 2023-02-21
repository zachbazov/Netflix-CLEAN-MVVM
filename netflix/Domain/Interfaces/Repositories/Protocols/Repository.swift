//
//  Repository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Repository Type

protocol Repository {
    var dataTransferService: DataTransferService { get }
    var task: Cancellable? { get set }
}
