//
//  CoreDataStorage.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import CoreData

// MARK: - CoreDataStorageError Type

enum CoreDataStorageError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}

// MARK: - CoreDataStorage Type

final class CoreDataStorage {
    static let shared = CoreDataStorage()
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        transformersDidRegister()

        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("CoreDataStorage unresolved error \(error), \(error.userInfo)")
            }
        }
//        printContainerUrl(for: container)
        return container
    }()
    
    private(set) lazy var mainContext: NSManagedObjectContext = createMainContext()
    
    private lazy var privateContext: NSManagedObjectContext = createPrivateContext()
    
    private func createMainContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.privateContext
        return context
    }
    
    private func createPrivateContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        return context
    }
}

// MARK: - Private UI Implementation

extension CoreDataStorage {
    private func printContainerUrl(for container: NSPersistentContainer) {
        let persistentStore = container.persistentStoreCoordinator.persistentStores.first!
        let url = container.persistentStoreCoordinator.url(for: persistentStore)
        printIfDebug(.url, "persistentStore url \(url)")
    }
    
    private func transformersDidRegister() {
        ValueTransformer.setValueTransformer(ValueTransformer<UserDTO>(),
                                             forName: .userTransformer)
        ValueTransformer.setValueTransformer(ValueTransformer<MediaDTO>(),
                                             forName: .mediaTransformer)
        ValueTransformer.setValueTransformer(ValueTransformer<MediaResourcesDTO>(),
                                             forName: .mediaResourcesTransformer)
    }
}

// MARK: - Methods

extension CoreDataStorage {
    func context() -> NSManagedObjectContext {
        return mainContext
    }
    
    func saveContext() {
        mainContext.performAndWait {
            do {
                guard mainContext.hasChanges else { return }
                try mainContext.save()
            } catch {
                assertionFailure("CoreDataStorage main context unresolved error \(error), \((error as NSError).userInfo)")
            }
            
            privateContext.perform { [weak self] in
                guard let self = self else { return }
                do {
                    guard self.privateContext.hasChanges else { return }
                    try self.privateContext.save()
                } catch {
                    assertionFailure("CoreDataStorage private context unresolved error \(error), \((error as NSError).userInfo)")
                }
            }
        }
    }
}
