//
//  AuthService.swift
//  netflix
//
//  Created by Zach Bazov on 20/11/2022.
//

import Foundation

// MARK: - AuthServiceProtocol Type

private protocol AuthServiceProtocol {
//    var user: UserDTO? { get }
//    var responses: UserHTTPResponseStore { get }
//
//    func setUser(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response)
//    func deleteResponse(for request: UserHTTPDTO.Request)
//
////    func resign(completion: @escaping (UserDTO?) -> Void)
//    func signIn(for requestDTO: UserHTTPDTO.Request, completion: @escaping (UserDTO?) -> Void)
//    func signUp(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void)
//    func signOut(_ completion: (() -> Void)?)
}

// MARK: - AuthService Type

class AuthService {
    var userId: String?
    var userToken: String?
    var userSelectedProfile: String?
    
    var user: UserDTO?
    
    fileprivate var responses: UserHTTPResponseStore {
        return Application.app.stores.userResponses
    }
}

// MARK: - AuthServiceProtocol Implementation

extension AuthService: AuthServiceProtocol {
    /// Assign and manipulate the `user` property.
    /// - Parameters:
    ///   - request: Request object via invocation.
    ///   - response: Response object via invocation.
    fileprivate func setUser(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response) {
        userId = response.data?._id
        userToken = response.token
        userSelectedProfile = request?.selectedProfile
        
        user = response.data
        user?._id = response.data?._id
        user?.token = response.token
        
        if let request = request {
            user?.password = request.user.password
        }
    }
    
    /// Delete all `user`'s related data and clean up service's attributes.
    /// - Parameter request: Request object via invocation.
    fileprivate func deleteResponse(for request: UserHTTPDTO.Request) {
        let sectionResponses = Application.app.stores.sectionResponses
        let mediaResponses = Application.app.stores.mediaResponses
        let context = Application.app.stores.userResponses.coreDataStorage.context()
        
        responses.deleteResponse(for: request, in: context)
        sectionResponses.deleteResponse(in: context)
        mediaResponses.deleteResponse(in: context)
        
        self.user = nil
    }
    
    /// Invoke a sign in request.
    /// - Parameters:
    ///   - request: Auth request object.
    ///   - completion: Completion handler.
    func signIn(for request: UserHTTPDTO.Request, completion: @escaping (UserDTO?) -> Void) {
        let viewModel = AuthViewModel()
        
        viewModel.signIn(
            requestDTO: request,
            cached: { [weak self] response in
                guard let self = self,
                      let response = response
                else { return }
                
                self.setUser(request: request, response: response)
                
                completion(response.data)
            },
            completion: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.setUser(request: request, response: response)
                    
                    completion(response.data)
                case .failure(let error):
                    printIfDebug(.error, "Unresolved error \(error)")
                    
                    completion(nil)
                }
            })
    }
    
    /// Invoke a sign up request.
    /// - Parameters:
    ///   - request: Auth request object.
    ///   - completion: Completion handler.
    func signUp(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void) {
        let viewModel = AuthViewModel()
        
        viewModel.signUp(requestDTO: requestDTO) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.setUser(request: requestDTO, response: response)
                
                completion(true)
            case .failure(let error):
                printIfDebug(.error, "Unresolved error \(error)")
                
                completion(false)
            }
        }
    }
    
    /// Invoke a sign out request.
    func signOut(_ completion: (() -> Void)?) {
        let viewModel = AuthViewModel()
        let profileViewModel = ProfileViewModel()
        let requestDTO = UserHTTPDTO.Request(user: user!, selectedProfile: nil)
        
        profileViewModel.updateUserProfileForSigningOut {
            viewModel.signOut() { result in
                switch result {
                case .success:
                    self.deleteResponse(for: requestDTO)
                    self.user = nil
                    
                    completion?()
                case .failure(let error):
                    printIfDebug(.error, "\(error)")
                }
            }
        }
    }
}
