//
//  Router+SeasonRepository.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

extension Router<SeasonRepository> {
    func request<T>(for response: T.Type,
                    request: SeasonHTTPDTO.Request,
                    completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
        guard let repository = repository as SeasonRepository? else { return nil }
        return repository.getSeason(request: request, completion: completion)
    }
}
