//
//  Router.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

final class Router<T: Repository> {
    let repository: T
    
    init(repository: T) {
        self.repository = repository
    }
}

extension Router: Routable {}
