//
//  ImageRepositoryEndpoints.swift
//  netflix
//
//  Created by Zach Bazov on 07/02/2023.
//

import Foundation

// MARK: - ImageRepositoryEndpoints Protocol

protocol ImageRepositoryEndpoints {
    static func getImage(with request: ImageHTTPDTO.Request) -> Endpoint<ImageHTTPDTO.Response>
}
