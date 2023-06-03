//
//  NewsHTTPDTO.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - NewsHTTPDTO Type

struct NewsHTTPDTO: HTTPRepresentable {
    struct Request {
        let queryParams: [String: Any]
    }
    
    struct Response: Decodable {
        let status: String
        var results: Int?
        let data: [MediaDTO]
    }
}

// MARK: - Mapping

extension NewsHTTPDTO.Response {
    func toCellViewModels() -> [NewsCollectionViewCellViewModel] {
        return data.map { NewsCollectionViewCellViewModel(with: $0.toDomain()) }
    }
}
