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
                        asynchrony {
                            // Authenticate the user.
                            self.authenticate(for: response)
                            printIfDebug(.debug, "MyResponse \(self.user?.toDomain())")
                            // Pass the data within the completion handler.
                            completion(self.user)
                        }
                        return
                    }
                    asynchrony {
                        // In case there isn't a valid response.
                        completion(nil)
                    }
                }
            case .failure(let error):
                printIfDebug(.error, "\(error)")
            }
        }
    }
    /// Cached authorization request.
    /// In case there is a registered last sign by a user in the cache,
    /// perform an authentication based on the cache data.
    func cachedAuthorizationRequest(completion: @escaping () -> Void) {
        printIfDebug(.debug, "cachedAuthorizationRequest \(user?.toDomain())")
        guard let email = user?.email,
              let password = user?.password else {
            return
        }
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = AuthRequestDTO(user: userDTO)
        let authViewModel = AuthViewModel()
        authViewModel.signIn(
            request: requestDTO.toDomain(),
            cached: { [weak self] responseDTO in
                printIfDebug(.debug, "cachedddd")
                guard let self = self, let responseDTO = responseDTO else { return }
                self.authenticate(for: responseDTO)
                completion()
            },
            completion: { [weak self] result in
                if case let .success(responseDTO) = result {
                    guard let self = self else { return }
                    printIfDebug(.debug, "comppppleee")
                    self.authenticate(for: responseDTO)
                    completion()
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "Unresolved error \(error)")
                }
            })
    }
    /// Authentication by response.
    /// Used for sign in and out authentication operations with a response object.
    /// This property is used by other features of the application.
    /// - Parameter response: API's response callback result object.
    func authenticate(for response: AuthResponseDTO?) {
        self.user = response?.data
        self.user?.password = response?.request?.user.password
        printIfDebug(.debug, "authenticate \(self.user?.toDomain())")
    }
    /// Authentication by user.
    /// Used for sign in authentication operation without a response object.
    /// This property is used by other features of the application.
    /// - Parameter user: User object.
    func authenticate(user: UserDTO) {
        self.user = user
    }
    /// Invoke a sign out request for the user.
    func deauthenticate() {
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

