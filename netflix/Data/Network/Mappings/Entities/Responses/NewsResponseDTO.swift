//
//  NewsResponseDTO.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

struct NewsResponseDTO: Decodable {
    let status: String
    let results: Int?
    let data: [MediaDTO]
}

extension NewsResponseDTO {
    func toCellViewModels() -> [NewsTableViewCellViewModel] {
        return data.map { NewsTableViewCellViewModel(media: $0) }
    }
}
