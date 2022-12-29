//
//  NewsResponseDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 20/12/2022.
//

import Foundation

// MARK: - NewsResponseDTO Type

struct NewsResponseDTO: Decodable {
    let status: String
    let results: Int?
    let data: [MediaDTO]
}

// MARK: - Mapping

extension NewsResponseDTO {
    func toCellViewModels() -> [NewsTableViewCellViewModel] {
        return data.map { NewsTableViewCellViewModel(with: $0.toDomain()) }
    }
}
