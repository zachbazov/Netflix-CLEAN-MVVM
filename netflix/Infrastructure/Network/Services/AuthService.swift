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
    
    func resign(completion: @escaping (UserDTO?) -> Void)
    func signIn(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void)
    func signUp(for requestDTO: UserHTTPDTO.Request, completion: @escaping (Bool) -> Void)
    func signOut()
}

private protocol AuthServiceOutput {
    var user: UserDTO? { get }
    var request: UserHTTPDTO.Request? { get }
    var response: UserHTTPDTO.Response? { get }
    var responses: AuthResponseStorage { get }
}

private typealias AuthServiceProtocol = AuthServiceInput & AuthServiceOutput

// MARK: - AuthService Type

class AuthService {
    var user: UserDTO?
    private(set) var request: UserHTTPDTO.Request?
    private(set) var response: UserHTTPDTO.Response?
    fileprivate var responses: AuthResponseStorage { return Application.app.stores.authResponses }
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
                    // In case there is a valid response.
                    if let response = response {
                        // Set authentication properties.
                        self.setResponse(request: response.request, response: response)
                        // Pass the data within the completion handler.
                        completion(self.user)
                        return
                    }
                    // In case there isn't a valid response.
                    completion(nil)
                }
            case .failure(let error):
                printIfDebug(.error, "\(error)")
            }
        }
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
                    
                    AlertView.shared.removeFromSuperview()
                    
                    completion(true)
                case .failure(let error):
                    printIfDebug(.error, "Unresolved error \(error)")
                    
                    AlertView.shared.present(state: .failure,
                                             title: "AUTHORIZATION",
                                             message: "Incorrect credentials.")
                    
                    completion(false)
                }
            })
    }
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
                
                AlertView.shared.present(state: .failure,
                                         title: "AUTHORIZATION",
                                         message: "Incorrect credentials.")
                
                completion(false)
            }
        }
    }
    /// Invoke a sign out request.
    func signOut() {
        // Create an auth request for the user.
        let requestDTO = UserHTTPDTO.Request(user: user!)
        // Perform a background task using core data storage.
        responses.coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            // Delete the request and the response objects cached for the user.
            self.responses.deleteResponse(for: requestDTO, in: context) {
                // Present indicator.
                ActivityIndicatorView.viewDidShow()
                
                let viewModel = AuthViewModel()
                // Invoke a sign out request.
                viewModel.signOut() { result in
                    switch result {
                    case .success:
                        // Deallocate authentication properties.
                        self.request = nil
                        self.response = nil
                        self.user = nil
                        
                        AlertView.shared.present(state: .success,
                                                 title: "AUTHORIZATION",
                                                 message: "Signed out successfully.")
                        // Hide indicator.
                        mainQueueDispatch(delayInSeconds: 3) {
                            ActivityIndicatorView.viewDidHide()
                        }
                        // Present the authentication screen.
                        mainQueueDispatch(delayInSeconds: 4) {
                            AlertView.shared.removeFromSuperview()
                            let coordinator = Application.app.coordinator
                            coordinator.coordinate(to: .auth)
                        }
                    case .failure(let error):
                        printIfDebug(.error, "\(error)")
                        
                        AlertView.shared.present(state: .failure,
                                                 title: "AUTHORIZATION",
                                                 message: "Unable to sign out.")
                    }
                }
            }
        }
    }
}
