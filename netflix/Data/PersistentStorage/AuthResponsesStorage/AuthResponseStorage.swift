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
                                        #keyPath(AuthRequestEntity.user.email),
                                        requestDTO.user.email!)
        return request
    }
    
    func getResponse(for request: AuthRequestDTO,
                     completion: @escaping (Result<AuthResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                let fetchRequest = self.fetchRequest(for: request)
                let requestEntity = try context.fetch(fetchRequest).first
                
                UserGlobal.user = requestEntity?.response?.data
                
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
                
                UserGlobal.user = response.data
                
                try context.save()
            } catch {
                printIfDebug("CoreDataAuthResponseStorage unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func deleteResponse(for request: AuthRequestDTO, in context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        let fetchRequest = AuthRequestEntity.fetchRequest()
        do {
            if let result = try context.fetch(fetchRequest) as [AuthRequestEntity]? {
                for r in result where r.user?.email ?? "" == UserGlobal.user?.email ?? "" {
                    print("deleting", r.user!.toDomain().email)
                    context.delete(r.response!)
                    context.delete(r)
                    
                    if context.hasChanges { try context.save() }
                    
                    completion?()
                }
            }
        } catch {
            printIfDebug("Unresolved error \(error) occured as trying to delete object.")
        }
    }
}
