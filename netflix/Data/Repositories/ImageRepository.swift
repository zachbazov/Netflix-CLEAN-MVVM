//
//  ImageRepository.swift
//  netflix
//
//  Created by Zach Bazov on 07/02/2023.
//

import Foundation

// MARK: - ImageRepository Type

//struct ImageRepository: Repository {
//    let dataTransferService: DataTransferService
//    var task: Cancellable? { willSet { task?.cancel() } }
//}
//
//// MARK: - ImageRepositoryProtocol Implementation
//
//extension ImageRepository: ImageRepositoryProtocol {
//    func getOne(request: ImageHTTPDTO.Request,
//                cached: @escaping (ImageHTTPDTO.Response?) -> Void,
//                completion: @escaping (Result<ImageHTTPDTO.Response, Error>) -> Void) -> Cancellable? {
//        let task = RepositoryTask()
//
//        guard !task.isCancelled else { return nil }
//        let endpoint = APIEndpoint.getImage(with: request)
//        task.networkTask = dataTransferService.request(with: endpoint, completion: { result in
//            switch result {
//            case .success(let response):
//                completion(.success(response))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        })
//
//        return task
//    }
//}
