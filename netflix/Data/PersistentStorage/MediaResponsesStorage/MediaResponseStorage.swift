//
//  MediaResponseStorage.swift
//  netflix
//
//  Created by Zach Bazov on 19/10/2022.
//

import CoreData

// MARK: - MediaResponseStorage Type

final class MediaResponseStorage {
    
    // MARK: Properties
    
    private let coreDataStorage: CoreDataStorage
    
    // MARK: Initializer
    
    init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
}

// MARK: - Methods

extension MediaResponseStorage {
    private func fetchRequest(for requestDTO: MediaRequestDTO.GET.One) -> NSFetchRequest<MediaRequestEntity> {
        let request: NSFetchRequest = MediaRequestEntity.fetchRequest()
        if requestDTO.slug != nil {
            request.predicate = NSPredicate(format: "%K = %@",
                                            #keyPath(MediaRequestEntity.slug),
                                            requestDTO.slug ?? "")
            return request
        }
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(MediaRequestEntity.identifier),
                                        requestDTO.id ?? "")
        return request
    }
    
    func getResponse(for request: MediaRequestDTO.GET.One,
                     completion: @escaping (Result<MediaResponseDTO.GET.One?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: request)
                let requestEntity = try context.fetch(fetchRequest).first
                
                completion(.success(requestEntity?.response?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func save(response: MediaResponseDTO.GET.One,
              for request: MediaRequestDTO.GET.One) {
        coreDataStorage.performBackgroundTask { context in
            do {
                self.deleteResponse(for: request, in: context)
                
                let requestEntity: MediaRequestEntity = request.toEntity(in: context)
                requestEntity.response = response.toEntity(in: context)
                
                try context.save()
            } catch {
                printIfDebug(.error, "CoreDataAuthResponseStorage unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func deleteResponse(for request: MediaRequestDTO.GET.One,
                        in context: NSManagedObjectContext) {
        let fetchRequest = self.fetchRequest(for: request)
        do {
            if let result = try context.fetch(fetchRequest) as [MediaRequestEntity]? {
                for r in result {
                    context.delete(r)
                    context.delete(r.response!)
                }
            }
        } catch {
            printIfDebug(.error, "Unresolved error \(error) occured as trying to delete object.")
        }
    }
}
