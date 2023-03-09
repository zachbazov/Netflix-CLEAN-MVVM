//
//  AuthService.swift
//  netflix
//
//  Created by Zach Bazov on 20/11/2022.
//

import Foundation

// MARK: - AuthServiceProtocol Type

private protocol AuthServiceInput {
    func setResponse(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response)
    func setUser(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response)
    func deleteResponse(for request: UserHTTPDTO.Request)
    
    func resign(completion: @escaping (UserDTO?) -> Void)
    func signIn(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void)
    func signUp(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void)
    
    func resign() async -> UserDTO?
    func signIn(with request: UserHTTPDTO.Request) async -> Bool
    func signUp(with request: UserHTTPDTO.Request) async -> Bool
    func signOut(with request: UserHTTPDTO.Request) async -> Bool
}

private protocol AuthServiceOutput {
    var user: UserDTO? { get }
    var request: UserHTTPDTO.Request? { get }
    var response: UserHTTPDTO.Response? { get }
    var responses: AuthResponseStorage { get }
    
    func signOut()
}

private typealias AuthServiceProtocol = AuthServiceInput & AuthServiceOutput

// MARK: - AuthService Type

class AuthService {
    var user: UserDTO?
    private(set) var request: UserHTTPDTO.Request?
    private(set) var response: UserHTTPDTO.Response?
    fileprivate var responses: AuthResponseStorage { return Application.app.stores.authResponses }
}

// MARK: - AuthServiceProtocol Implementation

extension AuthService: AuthServiceProtocol {
    /// Assign the user and its request-response properties.
    /// - Parameters:
    ///   - request: Request object via invocation.
    ///   - response: Response object via invocation.
    func setResponse(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response) {
        self.request = request
        self.response = response
        
        setUser(request: request, response: response)
    }
    /// Assign and manipulate the `user` property.
    /// - Parameters:
    ///   - request: Request object via invocation.
    ///   - response: Response object via invocation.
    fileprivate func setUser(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response) {
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
        let mediaResponses = Application.app.stores.mediaResponses
        let context = responses.coreDataStorage.context()
        responses.deleteResponse(for: request, in: context)
        mediaResponses.deleteResponse(in: context)
        
        self.request = nil
        self.response = nil
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
                mainQueueDispatch {
                    if let response = response {
                        self.setResponse(request: response.request, response: response)
                        
                        completion(self.user)
                        
                        return
                    }
                    
                    completion(nil)
                }
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
        
        setResponse(request: request, response: response)
        
        return user
    }
    /// Invoke a sign in request.
    /// - Parameters:
    ///   - request: Auth request object.
    ///   - completion: Completion handler.
    func signIn(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void) {
        let viewModel = AuthViewModel()
        
        viewModel.signIn(
            requestDTO: requestDTO,
            cached: { [weak self] responseDTO in
                guard let self = self, let responseDTO = responseDTO else { return }
                self.setResponse(request: requestDTO, response: responseDTO)
                
                completion(true)
            },
            completion: { [weak self] result in
                switch result {
                case .success(let responseDTO):
                    guard let self = self else { return }
                    self.setResponse(request: requestDTO, response: responseDTO)
                    
                    completion(true)
                case .failure(let error):
                    printIfDebug(.error, "Unresolved error \(error)")
                    
                    completion(false)
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
                
                self.setResponse(request: requestDTO, response: responseDTO)
                
                completion(true)
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
                
                completion(false)
            }
        }
    }
    /// Invoke a sign out request.
    func signOut() {
        let requestDTO = UserHTTPDTO.Request(user: user!)
        
        responses.coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            self.responses.deleteResponse(for: requestDTO, in: context) {
                ActivityIndicatorView.viewDidShow()
                
                let viewModel = AuthViewModel()
                
                viewModel.signOut() { result in
                    switch result {
                    case .success:
                        self.request = nil
                        self.response = nil
                        self.user = nil
                        
                        mainQueueDispatch {
                            let coordinator = Application.app.coordinator
                            coordinator.coordinate(to: .auth)
                        }
                    case .failure(let error):
                        printIfDebug(.error, "\(error)")
                    }
                }
            }
        }
    }
    /// Invoke an asynchronous sign in request.
    /// - Parameter request: User's request object.
    /// - Returns: A boolean that indicates of the response status.
    func signIn(with request: UserHTTPDTO.Request) async -> Bool {
        let viewModel = AuthViewModel()
        
        guard let response = await viewModel.signIn(with: request) else { return false }
        
        setResponse(request: request, response: response)
        
        return true
    }
    /// Invoke an asynchronous sign up request.
    /// - Parameter request: User's request object.
    /// - Returns: A boolean that indicates of the response status.
    func signUp(with request: UserHTTPDTO.Request) async -> Bool {
        let viewModel = AuthViewModel()
        
        guard let response = await viewModel.signUp(with: request) else { return false }
        
        setResponse(request: request, response: response)
        
        return true
    }
    /// Invoke an asynchronous sign out request.
    /// - Parameter request: User's request object.
    /// - Returns: A boolean that indicates of the response status.
    func signOut(with request: UserHTTPDTO.Request) async -> Bool {
        let viewModel = AuthViewModel()
        
        guard let response = await viewModel.signOut(with: request),
              response.status == "success" else { return false }
        
        deleteResponse(for: request)
        
        return true
    }
}
