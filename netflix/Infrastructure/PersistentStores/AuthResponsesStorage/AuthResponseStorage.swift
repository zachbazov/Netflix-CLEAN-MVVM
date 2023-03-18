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
    func fetchRequest(for requestDTO: UserHTTPDTO.POST.Request) -> NSFetchRequest<AuthRequestEntity> {
        let request: NSFetchRequest = AuthRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(AuthRequestEntity.userId),
                                        requestDTO.user._id ?? "")
        return request
    }
    
    func fetchRequest(for requestDTO: UserHTTPDTO.GET.Request) -> NSFetchRequest<AuthRequestEntity> {
        let request: NSFetchRequest = AuthRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(AuthRequestEntity.userId),
                                        requestDTO.user._id ?? "")
        return request
    }
    
    func fetchRequest(for requestDTO: UserHTTPDTO.PATCH.Request) -> NSFetchRequest<AuthRequestEntity> {
        let request: NSFetchRequest = AuthRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(AuthRequestEntity.userId),
                                        requestDTO.user._id ?? "")
        return request
    }
    
    func getResponse(completion: @escaping (Result<UserHTTPDTO.POST.Response?, CoreDataStorageError>) -> Void) {
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
    
    func getResponse(for request: UserHTTPDTO.POST.Request,
                     completion: @escaping (Result<UserHTTPDTO.POST.Response?, CoreDataStorageError>) -> Void) {
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
    
    func save(response: UserHTTPDTO.POST.Response, for request: UserHTTPDTO.POST.Request) {
        let context = coreDataStorage.context()
        
        deleteResponse(for: request, in: context)
        
        let requestEntity: AuthRequestEntity = request.toEntity(in: context)
        let responseEntity: AuthResponseEntity = response.toEntity(in: context)
        
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
        
        response.data?.token = response.token
        response.data?.password = request.user.password
        
        responseEntity.request = requestEntity
        responseEntity.token = response.token
        responseEntity.data = response.data
        
        do { try context.save() }
        catch { printIfDebug(.error, "CoreDataAuthResponseStorage unresolved error \(error), \((error as NSError).userInfo)") }
    }
    
    func save(response: UserHTTPDTO.PATCH.Response, for request: UserHTTPDTO.PATCH.Request) {
        let context = coreDataStorage.context()
        
        deleteResponse(for: request, in: context)
        
        let requestEntity: AuthRequestEntity = request.toEntity(in: context)
        let responseEntity: AuthResponseEntity? = response.toEntity(in: context)
        
        let token = authService.user?.token
        
        request.user._id = response.data?._id
        request.user.name = response.data?.name
        request.user.role = response.data?.role
        request.user.active = response.data?.active
        request.user.mylist = response.data?.mylist
        request.user.token = token
        request.user.profiles = response.data?.profiles
        request.user.selectedProfile = response.data?.selectedProfile
        
        requestEntity.response = responseEntity
        requestEntity.user = request.user
        requestEntity.userId = request.user._id
        
        response.data?.token = token
        response.data?.password = request.user.password
        
        responseEntity?.request = requestEntity
        responseEntity?.token = token
        responseEntity?.data = response.data
        print("saved", response)
        do { try context.save() }
        catch { printIfDebug(.error, "CoreDataAuthResponseStorage unresolved error \(error), \((error as NSError).userInfo)") }
    }
    
    func deleteResponse(for request: UserHTTPDTO.POST.Request,
                        in context: NSManagedObjectContext,
                        completion: (() -> Void)? = nil) {
        let fetchRequest = self.fetchRequest(for: request)
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
    
    func deleteResponse(for request: UserHTTPDTO.GET.Request,
                        in context: NSManagedObjectContext,
                        completion: (() -> Void)? = nil) {
        let fetchRequest = self.fetchRequest(for: request)
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
    
    func deleteResponse(for request: UserHTTPDTO.PATCH.Request,
                        in context: NSManagedObjectContext,
                        completion: (() -> Void)? = nil) {
        let fetchRequest = self.fetchRequest(for: request)
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
    
    func getResponse() async -> UserHTTPDTO.POST.Response? {
        let context = coreDataStorage.context()
        let fetchRequest = AuthResponseEntity.fetchRequest()
        guard let responseEntity = try? context.fetch(fetchRequest).first else { return nil }
        let response = responseEntity.toDTO()
        return response
    }
    
    func getResponse(for request: UserHTTPDTO.POST.Request) async -> UserHTTPDTO.POST.Response? {
        let context = coreDataStorage.context()
        let fetchRequest = AuthRequestEntity.fetchRequest()
        guard let requestEntity = try? context.fetch(fetchRequest).first else { return nil }
        let response = requestEntity.response?.toDTO()
        return response
    }
}
