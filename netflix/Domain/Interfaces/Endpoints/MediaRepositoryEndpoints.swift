//
//  MediaRepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - MediaRepositoryEndpoints Type

protocol MediaRepositoryEndpoints: SearchRepositoryEndpoints, NewsRepositoryEndpoints {
    static func getAllMedia() -> Endpoint<MediaHTTPDTO.Response>
    static func getMedia(with request: MediaHTTPDTO.Request) -> Endpoint<MediaHTTPDTO.Response>
}

// MARK: - SearchRepositoryEndpoints Type

protocol SearchRepositoryEndpoints {
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response>
}

// MARK: - NewsRepositoryEndpoints Type

protocol NewsRepositoryEndpoints {
    static func getUpcomingMedia(with request: NewsHTTPDTO.Request) -> Endpoint<NewsHTTPDTO.Response>
}
