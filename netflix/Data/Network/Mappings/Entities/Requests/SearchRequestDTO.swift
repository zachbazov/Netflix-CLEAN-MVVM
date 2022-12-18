//
//  SearchRequestDTO.swift
//  netflix
//
//  Created by Zach Bazov on 18/12/2022.
//

import Foundation

struct SearchRequestDTO: Encodable {
    let slug: String
    let page: Int?
}
