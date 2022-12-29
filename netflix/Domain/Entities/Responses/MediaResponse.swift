//
//  MediaResponse.swift
//  netflix
//
//  Created by Zach Bazov on 16/10/2022.
//

import Foundation

// MARK: - MediaResponse Type

struct MediaResponse {
    
    // MARK: GET Type
    
    struct GET {
        
        // MARK: One Type
        
        struct One {
            let status: String
            let data: Media
        }
        
        // MARK: Many Type
        
        struct Many {
            let status: String
            let results: Int
            let data: [Media]
        }
    }
}
