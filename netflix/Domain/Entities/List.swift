//
//  List.swift
//  netflix
//
//  Created by Zach Bazov on 20/10/2022.
//

import Foundation

// MARK: - List Type

struct List {
    struct GET {
        let user: String
        var media: [Media]
    }
    
    struct POST {
        let user: String
        var media: [String]
    }
}
