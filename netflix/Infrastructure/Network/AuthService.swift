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
    func performCachedAuthorizationSession(_ completion: @escaping (AuthRequest) -> Void) {
        guard let email = user?.email,
              let password = user?.password else {
            return
        }
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = AuthRequestDTO(user: userDTO)

        completion(requestDTO.toDomain())
    }
    /// Cached authorization session.
    /// In-case there is a registered last sign by a user in the cache,
    /// perform a re-sign operation.
    /// - Parameter completion: Completion handler.
    func cachedAuthorizationSession() {
        performCachedAuthorizationSession { [weak self] request in
            guard let self = self else { return }
            let authViewModel = AuthViewModel()
            authViewModel.signIn(
                request: request,
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

