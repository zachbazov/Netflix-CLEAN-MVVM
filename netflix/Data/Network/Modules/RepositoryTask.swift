//
//  RepositoryTask.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - RepositoryTask Type

final class RepositoryTask {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
}

// MARK: - Cancellable Implementation

extension RepositoryTask: Cancellable {
    func cancel() {
        networkTask?.cancel()
        
        isCancelled = true
    }
}
