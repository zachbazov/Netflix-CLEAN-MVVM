//
//  NewsHTTPDTO+Mapping.swift
//  netflix
//
//  Created by Zach Bazov on 01/02/2023.
//

import Foundation

// MARK: - NewsHTTPDTO Type

struct NewsHTTPDTO: HTTP {
    struct Request {
        let queryParams: [String: Any]
    }
    
    struct Response: Decodable {
        let status: String
        let results: Int?
        let data: [MediaDTO]
    }
}

// MARK: - Mapping

extension NewsHTTPDTO.Response {
    func toCellViewModels() -> [NewsTableViewCellViewModel] {
        return data.map { NewsTableViewCellViewModel(with: $0.toDomain()) }
    }
}
