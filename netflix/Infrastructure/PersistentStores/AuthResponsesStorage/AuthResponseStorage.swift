//
//  AuthResponseStorage.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - AuthResponseStorage Type

final class AuthResponseStorage {
    let coreDataStorage: CoreDataStorage
    private let authService: AuthService
    
    init(coreDataStorage: CoreDataStorage = .shared,
         authService: AuthService) {
        self.coreDataStorage = coreDataStorage
        self.authService = authService
    }
}

// MARK: - Methods

extension AuthResponseStorage {
    func fetchRequest(for requestDTO: UserHTTPDTO.Request) -> NSFetchRequest<AuthRequestEntity> {
        let request: NSFetchRequest = AuthRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(AuthRequestEntity.user),
                                        requestDTO.user)
        return request
    }
    
    func getResponse(completion: @escaping (Result<UserHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest: NSFetchRequest = AuthResponseEntity.fetchRequest()
                let responseEntity = try context.fetch(fetchRequest).first
                completion(.success(responseEntity?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func getResponse(for request: UserHTTPDTO.Request,
                     completion: @escaping (Result<UserHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                let fetchRequest: NSFetchRequest = self.fetchRequest(for: request)
                let requestEntity = try context.fetch(fetchRequest).first
                completion(.success(requestEntity?.response?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    func getResponse(for request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        let context = coreDataStorage.context()
        let fetchRequest = fetchRequest(for: request)
        guard let requestEntity = try? context.fetch(fetchRequest).first else { return nil }
        let response = requestEntity.response?.toDTO()
        return response
    }
    
    func save(response: UserHTTPDTO.Response, for request: UserHTTPDTO.Request) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                self.deleteResponse(for: request, in: context)
                
                let requestEntity: AuthRequestEntity = request.toEntity(in: context)
                let responseEntity: AuthResponseEntity = response.toEntity(in: context)
                
                request.user._id = response.data?._id
                request.user.name = response.data?.name
                request.user.role = response.data?.role
                request.user.active = response.data?.active
                request.user.mylist = response.data?.mylist
                request.user.token = response.token
                
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
    
    func deleteResponse(for request: UserHTTPDTO.Request,
                        in context: NSManagedObjectContext,
                        completion: (() -> Void)? = nil) {
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
