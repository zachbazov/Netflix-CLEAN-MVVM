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
    
    // MARK: Singleton Pattern
    
    static let shared = CoreDataStorage()
    private init() {}
    
    // MARK: Properties
    
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
}

// MARK: - UI Setup

extension CoreDataStorage {
    private func printContainerUrl(for container: NSPersistentContainer) {
        let persistentStore = container.persistentStoreCoordinator.persistentStores.first!
        let url = container.persistentStoreCoordinator.url(for: persistentStore)
        printIfDebug(.url, "persistentStore url \(url)")
    }
    
    private func transformersDidRegister() {
        ValueTransformer.setValueTransformer(ValueTransformer<UserDTO>(),
                                             forName: .userTransformer)
        ValueTransformer.setValueTransformer(ValueTransformer<MediaResourcesDTO>(),
                                             forName: .mediaResourcesTransformer)
    }
}

// MARK: - Methods

extension CoreDataStorage {
    func context() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else { return }
        
        do { try context.save() }
        catch { assertionFailure("CoreDataStorage unresolved error \(error), \((error as NSError).userInfo)") }
    }
}
