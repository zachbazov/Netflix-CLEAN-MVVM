//
//  AuthService.swift
//  netflix
//
//  Created by Zach Bazov on 20/11/2022.
//

import Foundation

// MARK: - AuthService Type

final class AuthService {
    private let coreDataStorage: CoreDataStorage = .shared
    private var authResponseStorage: AuthResponseStorage { Application.current.authResponseCache }
    private(set) var user: UserDTO?
    private(set) var request: UserHTTPDTO.Request?
    private(set) var response: UserHTTPDTO.Response?
}

// MARK: - Methods

extension AuthService {
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
    private func setUser(request: UserHTTPDTO.Request?, response: UserHTTPDTO.Response) {
        user = response.data
        user?._id = response.data?._id
        user?.token = response.token
        if let request = request {
            user?.password = request.user.password
        }
    }
    /// Check for the latest authentication response signed by user.
    /// In case there is a valid response, pass the user data with the completion.
    /// In case there isn't a valid response, pass nil with the completion.
    /// - Parameter completion: Completion handler that passes a valid or an invalid user data.
    func response(completion: @escaping (UserDTO?) -> Void) {
        authResponseStorage.getResponse { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                asynchrony {
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
    func signInRequest(requestDTO: UserHTTPDTO.Request, completion: @escaping () -> Void) {
        let viewModel = AuthViewModel()
        viewModel.signIn(
            requestDTO: requestDTO,
            cached: { [weak self] responseDTO in
                guard let self = self, let responseDTO = responseDTO else { return }
                self.setResponse(request: requestDTO, response: responseDTO)
                completion()
            },
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    guard let self = self else { return }
                    self.setResponse(request: requestDTO, response: responseDTO)
                    completion()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "Unresolved error \(error)")
                }
            })
    }
    /// Invoke a sign up request.
    /// - Parameters:
    ///   - request: Auth request object.
    ///   - completion: Completion handler.
    func signUpRequest(requestDTO: UserHTTPDTO.Request, completion: @escaping () -> Void) {
        let viewModel = AuthViewModel()
        viewModel.signUp(requestDTO: requestDTO) { [weak self] result in
            guard let self = self else { return }
            if case let .success(responseDTO) = result {
                self.setResponse(request: responseDTO.request, response: responseDTO)
                completion()
            }
            if case let .failure(error) = result {
                printIfDebug(.error, "\(error)")
            }
        }
    }
    /// Invoke a sign out request.
    func signOutRequest() {
        // Create an auth request for the user.
        let requestDTO = UserHTTPDTO.Request(user: user!)
        // Perform a background task using core data storage.
        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            // Delete the request and the response objects cached for the user.
            self.authResponseStorage.deleteResponse(for: requestDTO, in: context) {
                let authViewModel = AuthViewModel()
                // Invoke a sign out request.
                authViewModel.signOut() { result in
                    switch result {
                    case .success:
                        // Deallocate authentication properties.
                        self.request = nil
                        self.response = nil
                        self.user = nil
                        // Present the authentication screen.
                        asynchrony {
                            Application.current.rootCoordinator.showScreen(.auth)
                        }
                    case .failure(let error):
                        printIfDebug(.error, "\(error)")
                    }
                }
            }
        }
    }
}
