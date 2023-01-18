//
//  AuthResponseStorage.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - AuthResponseStorage Type

final class AuthResponseStorage {
    
    // MARK: Properties
    
    let coreDataStorage: CoreDataStorage
    private let authService: AuthService
    
    // MARK: Initializer
    
    init(coreDataStorage: CoreDataStorage = .shared,
         authService: AuthService) {
        self.coreDataStorage = coreDataStorage
        self.authService = authService
    }
}

// MARK: - Methods

extension AuthResponseStorage {
    func fetchRequest(for requestDTO: AuthRequestDTO) -> NSFetchRequest<AuthRequestEntity> {
        let request: NSFetchRequest = AuthRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(AuthRequestEntity.user),
                                        requestDTO.user)
        return request
    }
    
    func getResp(completion: @escaping (Result<AuthResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest: NSFetchRequest = AuthResponseEntity.fetchRequest()
                let responseEntity = try context.fetch(fetchRequest).first
//                printIfDebug(.debug, "getRes \(responseEntity?.data?.toDomain())")
                completion(.success(responseEntity?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func getResponse(for request: AuthRequestDTO,
                     completion: @escaping (Result<AuthResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                let fetchRequest = self.fetchRequest(for: request)
                let requestEntity = try context.fetch(fetchRequest).first
//                printIfDebug(.debug, "getResponse \(requestEntity?.user?.toDomain())")
                completion(.success(requestEntity?.response?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func save(response: AuthResponseDTO, for request: AuthRequestDTO) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                self.deleteResponse(for: request, in: context)
                
                let requestEntity: AuthRequestEntity = request.toEntity(in: context)
                let responseEntity: AuthResponseEntity = response.toEntity(in: context)
                
                requestEntity.response = responseEntity
                requestEntity.user = request.user
                
                responseEntity.request = requestEntity
                responseEntity.token = response.token
                responseEntity.data = response.data
                printIfDebug(.debug, "save \(responseEntity.data!.toDomain())")
                try context.save()
            } catch {
//                printIfDebug(.error, "CoreDataAuthResponseStorage unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func deleteResponse(for request: AuthRequestDTO, in context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        let fetchRequest = AuthRequestEntity.fetchRequest()
        do {
            if let result = try context.fetch(fetchRequest).first {
                context.delete(result)
//                printIfDebug(.debug, "deleteResponse \(result)")
                try context.save()
                
                completion?()
            }
        } catch {
            printIfDebug(.error, "Unresolved error \(error) occured as trying to delete object.")
        }
    }
}
