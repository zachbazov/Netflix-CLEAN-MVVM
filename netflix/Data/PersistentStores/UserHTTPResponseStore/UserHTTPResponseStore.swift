//
//  UserHTTPResponseStore.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - UserHTTPResponseStore Type

final class UserHTTPResponseStore {
    let coreDataStorage: CoreDataStorage
    private let authService: AuthService
    
    init(coreDataStorage: CoreDataStorage = .shared, authService: AuthService) {
        self.coreDataStorage = coreDataStorage
        self.authService = authService
    }
}

// MARK: - Methods

extension UserHTTPResponseStore {
    func fetchRequest(for requestDTO: UserHTTPDTO.Request) -> NSFetchRequest<UserHTTPRequestEntity> {
        let request: NSFetchRequest = UserHTTPRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(UserHTTPRequestEntity.userId),
                                        requestDTO.user._id ?? "")
        return request
    }
    
    func getResponse(completion: @escaping (Result<UserHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.context()
        do {
            let fetchRequest: NSFetchRequest = UserHTTPResponseEntity.fetchRequest()
            let responseEntity = try context.fetch(fetchRequest).first
            
            completion(.success(responseEntity?.toDTO()))
        } catch {
            completion(.failure(CoreDataStorageError.readError(error)))
        }
    }
    
    func getResponse(for request: UserHTTPDTO.Request,
                     completion: @escaping (Result<UserHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.context()
        do {
            let fetchRequest: NSFetchRequest = self.fetchRequest(for: request)
            let requestEntity = try context.fetch(fetchRequest).first
            completion(.success(requestEntity?.response?.toDTO()))
        } catch {
            completion(.failure(CoreDataStorageError.readError(error)))
        }
    }
    
    func save(response: UserHTTPDTO.Response, for request: UserHTTPDTO.Request) {
        let context = coreDataStorage.context()
        
        deleteResponse(for: request, in: context)
        
        let requestEntity: UserHTTPRequestEntity = request.toEntity(in: context)
        let responseEntity: UserHTTPResponseEntity = response.toEntity(in: context)
        
        request.user._id = response.data?._id
        request.user.name = response.data?.name
        request.user.role = response.data?.role
        request.user.active = response.data?.active
        request.user.mylist = response.data?.mylist
        request.user.token = response.token
        request.user.profiles = response.data?.profiles
        request.user.selectedProfile = response.data?.selectedProfile
        
        requestEntity.response = responseEntity
        requestEntity.user = request.user
        requestEntity.userId = request.user._id
        requestEntity.selectedProfile = request.selectedProfile
        
        response.data?.token = response.token
        response.data?.password = request.user.password
        
        responseEntity.request = requestEntity
        responseEntity.token = response.token
        responseEntity.data = response.data
        responseEntity.userId = response.data?._id
        
        coreDataStorage.saveContext()
    }
    
    func deleteResponse(for request: UserHTTPDTO.Request,
                        in context: NSManagedObjectContext,
                        completion: (() -> Void)? = nil) {
        let fetchRequest = self.fetchRequest(for: request)
        do {
            if let result = try context.fetch(fetchRequest).first {
                context.delete(result)
                
                coreDataStorage.saveContext()
                
                completion?()
            }
        } catch {
            printIfDebug(.error, "Unresolved error \(error) occured as trying to delete object.")
        }
    }
}
