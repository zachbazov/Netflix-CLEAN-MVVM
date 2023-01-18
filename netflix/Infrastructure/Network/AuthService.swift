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
    var user: UserDTO?
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
                    if let user = response?.data {
                        user.password = response?.request?.user.password
                        // Authenticate the user.
                        self.authenticate(user: user)
                        // Pass the data within the completion handler.
                        completion(user)
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
    /// Cached authorization session.
    /// In-case there is a registered last sign by a user in the cache,
    /// perform a re-sign operation.
    /// - Parameter completion: Completion handler.
    func cachedAuthorizationSession() {
        guard let email = user?.email,
              let password = user?.password else {
            return
        }
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = AuthRequestDTO(user: userDTO)
        let authViewModel = AuthViewModel()
        authViewModel.signIn(
            request: requestDTO.toDomain(),
            cached: { responseDTO in
//                    printIfDebug(.debug, "cachedAuthorizationSession cachedResponseeee \(responseDTO!)")
                let userDTO = responseDTO?.data
                userDTO?.token = responseDTO?.token
                
                self.authenticate(user: userDTO)
                // Grant access to the `TabBar` scene.
                asynchrony {
                    Application.current.rootCoordinator.tabCoordinator.allocateViewControllers()
                }
            },
            completion: { result in
                if case let .success(responseDTO) = result {
//                        printIfDebug(.debug, "completion")
                    let userDTO = responseDTO.data
                    userDTO?.token = responseDTO.token
                    // Reauthenticate the user.
                    self.authenticate(user: userDTO)
                    // Grant access to the `TabBar` scene.
                    asynchrony {
                        Application.current.rootCoordinator.tabCoordinator.allocateViewControllers()
                    }
                }
                if case let .failure(error) = result {
                    printIfDebug(.error, "Unresolved error \(error)")
                }
            })
    }
    
    func authenticate(user: UserDTO?) {
//        printIfDebug(.debug, "authenticate \(user!.toDomain())")
        self.user = user
    }
    
    func deauthenticate() {
//        printIfDebug(.debug, "deauthenticate")
        let requestDTO = AuthRequestDTO(user: user!)

        coreDataStorage.performBackgroundTask { [weak self] context in
            self?.authResponseStorage.deleteResponse(for: requestDTO, in: context) {

                let authViewModel = AuthViewModel()
                authViewModel.signOut() { result in
                    switch result {
                    case .success:
//                        UserDefaults.standard.removeObject(forKey: "latestAuthenticationOnDevice")
//                        UserDefaults.standard.removeObject(forKey: "latestAuthenticationPasswordOnDevice")
                        self?.user = nil

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

