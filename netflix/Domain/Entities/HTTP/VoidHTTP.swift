//
//  VoidHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 07/03/2023.
//

import Foundation

// MARK: - VoidHTTP Type

struct VoidHTTP: HTTP {
    typealias Request = Void
    
    struct Response {
        let status: String
        let message: String?
    }
}
