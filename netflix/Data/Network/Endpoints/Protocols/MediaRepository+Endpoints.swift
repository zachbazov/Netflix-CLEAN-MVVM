//
//  RepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - MediaRepositoryEndpoints Protocol

protocol MediaRepositoryEndpoints: SearchRepositoryEndpoints, NewsRepositoryEndpoints {
    static func getAllMedia() -> Endpoint<MediaHTTPDTO.Response>
    static func getMedia(with request: MediaHTTPDTO.Request) -> Endpoint<MediaHTTPDTO.Response>
}

// MARK: - SearchRepositoryEndpoints Protocol

protocol SearchRepositoryEndpoints {
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response>
}

// MARK: - NewsRepositoryEndpoints Protocol

protocol NewsRepositoryEndpoints {
    static func getUpcomingMedia(with request: NewsHTTPDTO.Request) -> Endpoint<NewsHTTPDTO.Response>
}
