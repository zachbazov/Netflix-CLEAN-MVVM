//
//  SeasonResponse.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonResponse Type

struct SeasonResponse {
    
    // MARK: GET Type
    
    struct GET {
        let status: String
        var data: Season?
    }
}
