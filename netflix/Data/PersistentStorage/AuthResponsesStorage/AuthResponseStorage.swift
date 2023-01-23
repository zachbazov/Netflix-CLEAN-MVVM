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
    
    func getResponse(for request: AuthRequestDTO? = nil,
                     completion: @escaping (Result<AuthResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                if let request = request {
                    let fetchRequest: NSFetchRequest = self.fetchRequest(for: request)
                    let requestEntity = try context.fetch(fetchRequest).first
                    printIfDebug(.debug, "getResponse \(requestEntity?.toDTO())")
                    return completion(.success(requestEntity?.response?.toDTO()))
                }
                let fetchRequest: NSFetchRequest = AuthResponseEntity.fetchRequest()
                let responseEntity = try context.fetch(fetchRequest).first
                printIfDebug(.debug, "getRes \(responseEntity?.request)")
                completion(.success(responseEntity?.toDTO()))
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
                
                response.data?.token = response.token
                response.data?.password = request.user.password
                
                responseEntity.request = requestEntity
                responseEntity.token = response.token
                responseEntity.data = response.data
                
                try context.save()
            } catch {
                printIfDebug(.error, "CoreDataAuthResponseStorage unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func deleteResponse(for request: AuthRequestDTO, in context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        let fetchRequest = AuthRequestEntity.fetchRequest()
        do {
            if let result = try context.fetch(fetchRequest).first {
                context.delete(result)
                
                try context.save()
                
                completion?()
            }
        } catch {
            printIfDebug(.error, "Unresolved error \(error) occured as trying to delete object.")
        }
    }
}
