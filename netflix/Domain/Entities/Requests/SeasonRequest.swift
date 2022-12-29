//
//  SeasonRequest.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import Foundation

// MARK: - SeasonRequest Type

struct SeasonRequest {
    
    // MARK: GET Type
    
    struct GET {
        var id: String? = nil
        var slug: String? = nil
        var season: Int? = 1
    }
}
