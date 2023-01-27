//
//  MediaResponse.swift
//  netflix
//
//  Created by Zach Bazov on 16/10/2022.
//

import Foundation

// MARK: - MediaResponse Type

struct MediaResponse {
    let status: String
    let results: Int
    let data: [Media]
}
