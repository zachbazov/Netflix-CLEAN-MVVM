//
//  ListRepositoryProtocol.swift
//  netflix
//
//  Created by Zach Bazov on 03/02/2023.
//

import Foundation

// MARK: - ListRepositoryProtocol Protocol

protocol ListRepositoryProtocol {
    var dataTransferService: DataTransferService { get }
    
    func getOne(request: ListHTTPDTO.GET.Request,
                completion: @escaping (Result<ListHTTPDTO.GET.Response, Error>) -> Void) -> Cancellable?
    func updateOne(request: ListHTTPDTO.PATCH.Request,
                   completion: @escaping (Result<ListHTTPDTO.PATCH.Response, Error>) -> Void) -> Cancellable?
}
