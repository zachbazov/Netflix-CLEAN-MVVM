//
//  AuthViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import Foundation

// MARK: - AuthViewModelDelegate Protocol

protocol AuthViewModelDelegate {
    func requestUserCredentials()
}

// MARK: - AuthViewModel Type

final class AuthViewModel {
    
    // MARK: ViewModel's Properties
    
    var coordinator: AuthCoordinator?
    
    // MARK: Type's Properties
    
    private let useCase: AuthUseCase
    private let authService = Application.current.authService
    private var authorizationTask: Cancellable? { willSet { authorizationTask?.cancel() } }
    
    // MARK: Initializer
    
    /// Default initializer.
    /// Allocate `useCase` property and it's dependencies.
    init() {
        let dataTransferService = Application.current.dataTransferService
        let authResponseCache = Application.current.authResponseCache
        let authRepository = AuthRepository(dataTransferService: dataTransferService, cache: authResponseCache)
        self.useCase = AuthUseCase(authRepository: authRepository)
    }
    
    // MARK: Deinitializer
    
    deinit {
        coordinator = nil
        authorizationTask = nil
    }
}

// MARK: - ViewModel's Implementation

extension AuthViewModel: ViewModel {
    func transform(input: Void) {}
}

// MARK: - AuthUseCase Implementation

extension AuthViewModel {
    /// Use-case's sign-up operation.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - completion: Completion handler with a response.
    func signUp(request: AuthRequest,
                completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        let requestValue = AuthUseCaseRequestValue(method: .signup, request: request)
        authorizationTask = useCase.execute(
            requestValue: requestValue,
            cached: { _ in },
            completion: { result in
                if case let .success(responseDTO) = result { completion(.success(responseDTO)) }
                if case let .failure(error) = result { completion(.failure(error)) }
            })
    }
    /// Use-case's sign-in operation.
    /// - Parameters:
    ///   - request: Representation of the candidate user for the operation.
    ///   - completion: Completion handler with a response.
    func signIn(request: AuthRequest,
                cached: @escaping (AuthResponseDTO?) -> Void,
                completion: @escaping (Result<AuthResponseDTO, Error>) -> Void) {
        let requestValue = AuthUseCaseRequestValue(method: .signin, request: request)
        authorizationTask = useCase.execute(
            requestValue: requestValue,
            cached: { response in
                printIfDebug(.debug, "signIn cachedResponseeee \(response!)")
                cached(response)
            },
            completion: { result in
                if case let .success(responseDTO) = result { completion(.success(responseDTO)) }
                if case let .failure(error) = result { completion(.failure(error)) }
            })
    }
    /// Cached authorization session.
    /// In-case there is a registered last sign by a user in the cache,
    /// perform a re-sign operation.
    /// - Parameter completion: Completion handler.
    func cachedAuthorizationSession(_ completion: @escaping () -> Void) {
        authService.performCachedAuthorizationSession { [weak self] request in
            guard let self = self else { return }
            self.signIn(
                request: request,
                cached: { responseDTO in
                    printIfDebug(.debug, "cachedAuthorizationSession cachedResponseeee \(responseDTO!)")
                    let userDTO = responseDTO?.data
                    userDTO?.token = responseDTO?.token
                    // Reauthenticate the user.
                    self.authService.authenticate(user: userDTO)
                    // Grant access to the `TabBar` scene.
                    completion()
                },
                completion: { result in
                    if case let .success(responseDTO) = result {
                        printIfDebug(.debug, "completion")
                        let userDTO = responseDTO.data
                        userDTO?.token = responseDTO.token
                        // Reauthenticate the user.
                        self.authService.authenticate(user: userDTO)
                        // Grant access to the `TabBar` scene.
                        completion()
                    }
                    if case let .failure(error) = result {
                        printIfDebug(.error, "Unresolved error \(error)")
                    }
                })
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        authorizationTask = useCase.execute(
            cached: { response in
                printIfDebug(.debug, "cachedSignOut \(response!)")
            },
            completion: { result in
                switch result {
                case .success(let void):
                    completion(.success(void))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
    }
}
