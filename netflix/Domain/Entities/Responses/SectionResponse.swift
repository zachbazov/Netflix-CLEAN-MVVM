//
//  SectionResponse.swift
//  netflix
//
//  Created by Zach Bazov on 08/09/2022.
//

import Foundation

// MARK: - SectionResponse Type

struct SectionResponse {
    
    // MARK: GET Type
    
    struct GET {
        let status: String
        let results: Int
        let data: [Section]
    }
}
