//
//  VoidHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 07/03/2023.
//

import Foundation

// MARK: - VoidHTTP Type

struct VoidHTTP: HTTPRepresentable {
    struct Request {}
    
    struct Response {
        let status: String
        var message: String?
    }
}
