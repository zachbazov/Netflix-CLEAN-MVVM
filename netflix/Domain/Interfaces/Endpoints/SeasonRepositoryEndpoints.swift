//
//  SeasonRepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 02/02/2023.
//

import Foundation

// MARK: - SeasonRepositoryEndpoints Protocol

protocol SeasonRepositoryEndpoints {
    static func getSeason(with request: SeasonHTTPDTO.Request) -> Endpoint<SeasonHTTPDTO.Response>
}
