//
//  SectionRepositoryProtocol.swift
//  netflix
//
//  Created by Zach Bazov on 03/02/2023.
//

import Foundation

// MARK: - SectionRepositoryProtocol Protocol

protocol SectionRepositoryProtocol {
    func getAll(completion: @escaping (Result<SectionHTTPDTO.Response, Error>) -> Void) -> Cancellable?
}