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
    private var authResponseStorage: AuthResponseStorage {
        return Application.current.authResponseCache
    }
    private(set) var user: UserDTO?
}

// MARK: - Methods

extension AuthService {
    /// Set and manipulate the `user` property.
    /// - Parameters:
    ///   - request: Auth request object.
    ///   - response: Auth response object.
    func setUser(request: AuthRequestDTO?, response: AuthResponseDTO) {
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
                        // Set the user.
                        self.setUser(request: nil, response: response)
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
    /// In case there is a stored response for the user in the cache,
    /// perform an authentication based on the cache data.
    func signInRequest(request: AuthRequestDTO, completion: @escaping () -> Void) {
        let viewModel = AuthViewModel()
        viewModel.signIn(
            request: request.toDomain(),
            cached: { [weak self] responseDTO in
                printIfDebug(.debug, "cachedddd")
                guard let self = self, let responseDTO = responseDTO else { return }
                self.setUser(request: request, response: responseDTO)
                completion()
            },
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    guard let self = self else { return }
                    printIfDebug(.debug, "comppppleee")
                    self.setUser(request: request, response: responseDTO)
                    completion()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "Unresolved error \(error)")
                }
            })
    }
    /// Invoke a sign out request for the user.
    func signOutRequest() {
        // Create an auth request for the user.
        let requestDTO = AuthRequestDTO(user: user!)
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
                        // Deallocate the user property.
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
