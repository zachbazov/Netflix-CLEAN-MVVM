//
//  MediaRepositoryProtocol.swift
//  netflix
//
//  Created by Zach Bazov on 03/02/2023.
//

import Foundation

// MARK: - MediaRepositoryProtocol Protocol

protocol MediaRepositoryProtocol {
    func getAll(cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable?
    func getOne(request: MediaHTTPDTO.Request,
                cached: @escaping (MediaHTTPDTO.Response?) -> Void,
                completion: @escaping (Result<MediaHTTPDTO.Response, Error>) -> Void) -> Cancellable?
}
