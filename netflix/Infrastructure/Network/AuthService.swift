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
        Application.current.authResponseCache
    }
}

// MARK: - Methods

extension AuthService {
    func performCachedAuthorizationSession(_ completion: @escaping (AuthRequest) -> Void) {
        guard let email = UserGlobal.user?.email,
              let password = UserGlobal.password as String? else {
            return
        }
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = AuthRequestDTO(user: userDTO)
        
        completion(requestDTO.toDomain())
    }

    func authenticate(user: UserDTO?) {
        UserGlobal.user = user
        if let password = user?.password {
            UserGlobal.password = password
        }
    }
    
    func deauthenticate() {
        let requestDTO = AuthRequestDTO(user: UserGlobal.user!)
        
        coreDataStorage.performBackgroundTask { [weak self] context in
            self?.authResponseStorage.deleteResponse(for: requestDTO, in: context) {
                
                let authViewModel = AuthViewModel()
                
                authViewModel.signOut() { result in
                    switch result {
                    case .success:
                        UserDefaults.standard.removeObject(forKey: "latestAuthenticationOnDevice")
                        UserDefaults.standard.removeObject(forKey: "latestAuthenticationPasswordOnDevice")
                        UserGlobal.user = nil
                        UserGlobal.password = nil
                        
                        asynchrony {
                            Application.current.rootCoordinator.showScreen(.auth)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

