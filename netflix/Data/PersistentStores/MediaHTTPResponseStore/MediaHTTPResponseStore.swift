//
//  MediaHTTPResponseStore.swift
//  netflix
//
//  Created by Zach Bazov on 19/10/2022.
//

import CoreData

// MARK: - MediaHTTPResponseStore Type

final class MediaHTTPResponseStore {
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
}

// MARK: - Methods

extension MediaHTTPResponseStore {
    private func fetchRequest() -> NSFetchRequest<MediaHTTPResponseEntity> {
        let request: NSFetchRequest = MediaHTTPResponseEntity.fetchRequest()
        return request
    }
    
    func getResponse(completion: @escaping (Result<MediaHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.context()
        do {
            let fetchRequest = self.fetchRequest()
            let responseEntity = try context.fetch(fetchRequest).first
            completion(.success(responseEntity?.toDTO()))
        } catch {
            completion(.failure(CoreDataStorageError.readError(error)))
        }
    }
    
    func save(response: MediaHTTPDTO.Response) {
        let context = coreDataStorage.context()
        
        deleteResponse(in: context)
        
        let responseEntity: MediaHTTPResponseEntity = response.toEntity(in: context)
        responseEntity.status = response.status
        responseEntity.results = Int32(response.results)
        responseEntity.data = response.data
        
        coreDataStorage.saveContext()
    }
    
    func deleteResponse(in context: NSManagedObjectContext) {
        let fetchRequest = self.fetchRequest()
        do {
            if let result = try context.fetch(fetchRequest).first {
                context.delete(result)
                
                coreDataStorage.saveContext()
            }
        } catch {
            printIfDebug(.error, "CoreDataMediaResponseStorage Unresolved error \((error as NSError).userInfo) occured trying to delete a response.")
        }
    }
}
