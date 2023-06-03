//
//  SectionHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - SectionHTTP Type

struct SectionHTTP: HTTPRepresentable {
    struct Request {
        let user: User
    }
    
    struct Response {
        let status: String
        let results: Int
        let data: [Section]
    }
}
