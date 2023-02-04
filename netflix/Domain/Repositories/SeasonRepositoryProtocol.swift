//
//  SeasonRepositoryProtocol.swift
//  netflix
//
//  Created by Zach Bazov on 03/02/2023.
//

import Foundation

// MARK: - SeasonRepositoryProtocol Protocol

protocol SeasonRepositoryProtocol {
    var dataTransferService: DataTransferService { get }
    
    func getSeason(request: SeasonHTTPDTO.Request,
                   completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable?
}
