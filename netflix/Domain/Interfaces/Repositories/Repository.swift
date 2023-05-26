//
//  Repository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

// MARK: - Repository Type

class Repository {
    let dataTransferService: DataServiceTransferring
    
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    init(dataTransferService: DataServiceTransferring) {
        self.dataTransferService = dataTransferService
    }
}

// MARK: - Taskable Implementation

extension Repository: Taskable {}

// MARK: - TransferableDataService Implementation

extension Repository: TransferableDataService {}
