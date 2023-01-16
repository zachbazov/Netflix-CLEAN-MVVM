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
    
    let userDefaults = UserDefaults.standard
    
    var user: UserDTO?
}

// MARK: - Methods

extension AuthService {
    func performCachedAuthorizationSession(_ completion: @escaping (AuthRequest) -> Void) {
        print("performCachedAuthorizationSession")
        guard let email = UserGlobal.user?.email,
              let password = UserGlobal.password as String? else {
            return
        }
        let userDTO = UserDTO(email: email, password: password)
        let requestDTO = AuthRequestDTO(user: userDTO)
        
        completion(requestDTO.toDomain())
    }

    func authenticate(user: UserDTO?) {
        print("authenticate", user?.toDomain())
        self.user = user
    }
    
    func deauthenticate() {
//        let authService = Application.current.authService
        
        print("deauthenticate")
        let userDTO = UserDTO(_id: UserGlobal.user?._id, name: UserGlobal.user?.name, email: UserGlobal.user?.email, password: UserGlobal.password, passwordConfirm: UserGlobal.user?.passwordConfirm, role: UserGlobal.user?.role, active: UserGlobal.user?.active, token: UserGlobal.user?.token, mylist: UserGlobal.user?.mylist)
        let requestDTO = AuthRequestDTO(user: userDTO)
        
        coreDataStorage.performBackgroundTask { [weak self] context in
            print("Acc11", UserGlobal.user!.toDomain())
            self?.authResponseStorage.deleteResponse(for: requestDTO, in: context) {
                
                let authViewModel = AuthViewModel()
                let authRequest = AuthRequest(user: UserGlobal.user!.toDomain())
                print("Acc22", UserGlobal.user!.toDomain())
                authViewModel.signOut(request: authRequest) { _ in
                    UserDefaults.standard.removeObject(forKey: "latestAuthenticationOnDevice")
                    UserDefaults.standard.removeObject(forKey: "latestAuthenticationPasswordOnDevice")
                    self?.user = nil
                    UserGlobal.user = nil
                    UserGlobal.password = nil
                    
                    asynchrony {
                        Application.current.rootCoordinator.showScreen(.auth)
                    }
                }
            }
        }
    }
}

