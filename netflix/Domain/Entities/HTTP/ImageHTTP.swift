//
//  ImageHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 07/02/2023.
//

import Foundation

// MARK: - ImageHTTP Type

struct ImageHTTP {
    struct Request {
        let name: String
        var type: String?
    }
    
    struct Response {
        let status: String
        let results: Int
        let data: [Image]
    }
}
