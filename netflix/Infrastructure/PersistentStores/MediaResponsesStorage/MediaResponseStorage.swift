//
//  MediaResponseStorage.swift
//  netflix
//
//  Created by Zach Bazov on 19/10/2022.
//

import CoreData

// MARK: - MediaResponseStorage Type

final class MediaResponseStorage {
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
}

// MARK: - Methods

extension MediaResponseStorage {
    private func fetchRequest() -> NSFetchRequest<MediaResponseEntity> {
        let request: NSFetchRequest = MediaResponseEntity.fetchRequest()
        return request
    }
    
    func getResponse(completion: @escaping (Result<MediaHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest()
                let responseEntity = try context.fetch(fetchRequest).first
                completion(.success(responseEntity?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func getResponse() async -> MediaHTTPDTO.Response? {
        let context = coreDataStorage.context()
        do {
            let fetchRequest = self.fetchRequest()
            let responseEntity = try context.fetch(fetchRequest).first
            let response = responseEntity?.toDTO()
            return response
        } catch {
            printIfDebug(.error, "CoreDataMediaResponseStorage unresolved error \(CoreDataStorageError.readError(error)) occured trying to fetch a response.")
        }
        return nil
    }
    
    func save(response: MediaHTTPDTO.Response) {
        let context = coreDataStorage.context()
        do {
            self.deleteResponse(in: context)
            
            let responseEntity: MediaResponseEntity = response.toEntity(in: context)
            responseEntity.status = response.status
            responseEntity.results = Int32(response.results)
            responseEntity.data = response.data
            
            try context.save()
        } catch {
            printIfDebug(.error, "CoreDataMediaResponseStorage unresolved error \(error), \((error as NSError).userInfo) occured trying to save a response.")
        }
    }
    
    func deleteResponse(in context: NSManagedObjectContext) {
        let fetchRequest = self.fetchRequest()
        do {
            if let result = try context.fetch(fetchRequest).first {
                context.delete(result)
                
                try context.save()
            }
        } catch {
            printIfDebug(.error, "CoreDataMediaResponseStorage Unresolved error \((error as NSError).userInfo) occured trying to delete a response.")
        }
    }
}
