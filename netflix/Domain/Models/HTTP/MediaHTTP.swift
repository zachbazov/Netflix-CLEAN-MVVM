//
//  MediaHTTP.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - MediaHTTP Type

struct MediaHTTP: HTTPRepresentable {
    struct Request {
        var user: UserDTO?
        let media: MediaHTTPDTO.Request
    }
    
    struct Response {
        let status: String
        let results: Int
        let data: [Media]
    }
}
