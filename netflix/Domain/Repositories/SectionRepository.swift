//
//  SectionRepository.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import Foundation

// MARK: - SectionsRepositoryRouting Type

protocol SectionsRepositoryRouting {
    static func getAllSections() -> Endpoint<SectionHTTPDTO.Response>
}

// MARK: - SectionRepository Type

final class SectionRepository: Repository {
    let dataTransferService: DataServiceTransferring
    
    let persistentStore: SectionHTTPResponseStore
    
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    init(dataTransferService: DataServiceTransferring, persistentStore: SectionHTTPResponseStore) {
        self.dataTransferService = dataTransferService
        self.persistentStore = persistentStore
    }
}

// MARK: - SectionsRepositoryRouting Implementation

extension SectionRepository: SectionsRepositoryRouting {
    static func getAllSections() -> Endpoint<SectionHTTPDTO.Response> {
        return Endpoint(path: "api/v1/sections",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["sort": "id"])
    }
}

// MARK: - SectionRepositoryProtocol Implementation

extension SectionRepository {
    func find<T>(request: Any?,
                 cached: @escaping (T?) -> Void,
                 completion: @escaping (Result<T, DataTransferError>) -> Void) -> Cancellable? where T: Decodable {
        let task = RepositoryTask()
        
        persistentStore.getResponse { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(response?) = result {
                return cached(response as? T)
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = SectionRepository.getAllSections()
            
            task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.persistentStore.save(response: response)
                    
                    completion(.success(response as! T))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
}
