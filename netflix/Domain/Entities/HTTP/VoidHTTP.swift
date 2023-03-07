//
//  VoidHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 07/03/2023.
//

import Foundation

// MARK: - VoidHTTP Type

struct VoidHTTP {
    struct Response: Decodable {
        let status: String
    }
}
