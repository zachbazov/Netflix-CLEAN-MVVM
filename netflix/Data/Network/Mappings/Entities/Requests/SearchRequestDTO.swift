//
//  SearchRequestDTO.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

// MARK: - SearchRequestDTO Type

struct SearchRequestDTO: Encodable {
    let regex: String
}
