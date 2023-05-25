//
//  AuthService.swift
//  netflix
//
//  Created by Zach Bazov on 20/11/2022.
//

import Foundation

// MARK: - AuthServiceProtocol Type

private protocol AuthServiceProtocol {
    var user: UserDTO? { get }
    var responses: UserHTTPResponseStore { get }
    
    func setUser(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response)
    func deleteResponse(for request: UserHTTPDTO.Request)
    
    func resign(completion: @escaping (UserDTO?) -> Void)
    func signIn(for requestDTO: UserHTTPDTO.Request, completion: @escaping (UserDTO?) -> Void)
    func signUp(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void)
    func signOut(_ completion: (() -> Void)?)
    
    func deleteResponse(for request: UserHTTPDTO.Request) async
    
    func resign() async -> UserDTO?
    func signIn(with request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response?
    func signUp(with request: UserHTTPDTO.Request) async -> Bool
    func signOut(with request: UserHTTPDTO.Request) async -> Bool
}

// MARK: - AuthService Type

class AuthService {
    var userId: String?
    var userToken: String?
    var userSelectedProfile: String?
    
    var user: UserDTO?
    
    fileprivate var responses: UserHTTPResponseStore { return Application.app.stores.userResponses }
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
    
    fileprivate func deleteResponse(for request: UserHTTPDTO.Request) async {
        let sectionResponses = Application.app.stores.sectionResponses
        let mediaResponses = Application.app.stores.mediaResponses
        let context = Application.app.stores.userResponses.coreDataStorage.context()
        responses.deleteResponse(for: request, in: context)
        sectionResponses.deleteResponse(in: context)
        mediaResponses.deleteResponse(in: context)
        
        self.user = nil
    }
    
    /// Check for the latest authentication response signed by user.
    /// In case there is a valid response, pass the user data with the completion.
    /// In case there isn't a valid response, pass nil with the completion.
    /// - Parameter completion: Completion handler that passes a valid or an invalid user data.
    func resign(completion: @escaping (UserDTO?) -> Void) {
        responses.getResponse { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let response = response {
                    self.setUser(request: response.request, response: response)
                    
                    completion(self.user)
                    
                    return
                }
                
                completion(nil)
            case .failure(let error):
                printIfDebug(.error, "\(error)")
            }
        }
    }
    
    /// Check for the latest authentication response signed by user.
    /// In case there is a valid response, return user object.
    /// In case there isn't a valid response, return nil.
    /// - Returns: A user object.
    func resign() async -> UserDTO? {
        guard let response = await responses.getResponse() else { return nil }
        
        let request = response.request
        let user = response.data
        
        setUser(request: request, response: response)
        
        return user
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
                guard let self = self, let response = response else { return }
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
            if case let .success(responseDTO) = result {
                
                self.setUser(request: requestDTO, response: responseDTO)
                
                completion(true)
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
                
                completion(false)
            }
        }
    }
    
    /// Invoke a sign out request.
    func signOut(_ completion: (() -> Void)?) {
        let coordinator = Application.app.coordinator
        let context = responses.coreDataStorage.context()
        let group = DispatchGroup()
        let viewModel = AuthViewModel()
        let profileViewModel = coordinator.profileCoordinator.viewController?.viewModel
        let requestDTO = UserHTTPDTO.Request(user: user!, selectedProfile: nil)
        
        group.enter()
        
        profileViewModel?.updateUserProfileForSigningOut { group.leave() }
        
        group.enter()
        
        viewModel.signOut() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.responses.deleteResponse(for: requestDTO, in: context) { group.leave() }
                
                self.user = nil
                
                completion?()
            case .failure(let error):
                printIfDebug(.error, "\(error)")
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            ActivityIndicatorView.remove()
            
            coordinator.coordinate(to: .auth)
        }
    }
    
    /// Invoke an asynchronous sign in request.
    /// - Parameter request: User's request object.
    /// - Returns: A boolean that indicates of the response status.
    func signIn(with request: UserHTTPDTO.Request) async -> UserHTTPDTO.Response? {
        let viewModel = AuthViewModel()
        
        guard let response = await viewModel.signIn(with: request) else { return nil }
        
        setUser(request: request, response: response)
        
        return response
    }
    
    /// Invoke an asynchronous sign up request.
    /// - Parameter request: User's request object.
    /// - Returns: A boolean that indicates of the response status.
    func signUp(with request: UserHTTPDTO.Request) async -> Bool {
        let viewModel = AuthViewModel()
        
        guard let response = await viewModel.signUp(with: request) else { return false }
        
        setUser(request: request, response: response)
        
        return true
    }
    
    /// Invoke an asynchronous sign out request.
    /// - Parameter request: User's request object.
    /// - Returns: A boolean that indicates of the response status.
    func signOut(with request: UserHTTPDTO.Request) async -> Bool {
        let viewModel = AuthViewModel()
        let profileViewModel = ProfileViewModel()
        
        let status = await profileViewModel.updateUserProfileForSigningOut()
        
        guard status else { return false }
        
        let response = await viewModel.signOut(with: request)
        
        guard let status = response?.status, status == .success else { return false }
        
        await deleteResponse(for: request)
        
        return true
    }
}
