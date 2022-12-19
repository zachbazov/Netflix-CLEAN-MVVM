//
//  SearchResponseDTO.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

struct SearchResponseDTO: Decodable {
    let status: String
    let results: Int
    let data: [MediaDTO]
}
