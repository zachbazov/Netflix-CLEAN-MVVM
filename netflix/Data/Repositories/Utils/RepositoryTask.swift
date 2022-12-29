//
//  RepositoryTask.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - RepositoryTask Type

final class RepositoryTask: Cancellable {
    
    // MARK: Properties
    
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    // MARK: Methods
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
