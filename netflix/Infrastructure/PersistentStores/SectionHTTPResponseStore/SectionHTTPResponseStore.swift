//
//  SectionHTTPResponseStore.swift
//  netflix
//
//  Created by Zach Bazov on 22/03/2023.
//

import CoreData

// MARK: - SectionHTTPResponseStore Type

final class SectionHTTPResponseStore {
    let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
}

extension SectionHTTPResponseStore {
    func fetchRequest() -> NSFetchRequest<SectionHTTPResponseEntity> {
        let request: NSFetchRequest = SectionHTTPResponseEntity.fetchRequest()
        return request
    }
    
    func getResponse(completion: @escaping (Result<SectionHTTPDTO.Response?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.context()
        do {
            let fetchRequest: NSFetchRequest = self.fetchRequest()
            let responseEntity = try context.fetch(fetchRequest).first
            completion(.success(responseEntity?.toDTO()))
        } catch {
            completion(.failure(CoreDataStorageError.readError(error)))
        }
    }
    
    func getResponse() async -> SectionHTTPDTO.Response? {
        let context = coreDataStorage.context()
        do {
            let fetchRequest: NSFetchRequest = self.fetchRequest()
            let responseEntity = try context.fetch(fetchRequest).first
            guard let response = responseEntity?.toDTO() else { return nil }
            return response
        } catch {
            return nil
        }
    }
    
    func save(response: SectionHTTPDTO.Response) {
        let context = coreDataStorage.context()
        
        deleteResponse(in: context)
        
        let responseEntity: SectionHTTPResponseEntity = response.toEntity(in: context)
        
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
            printIfDebug(.error, "Unresolved error \(error) occured as trying to delete object.")
        }
    }
}
