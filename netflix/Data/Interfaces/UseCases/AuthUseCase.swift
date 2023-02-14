//
//  AuthUseCase.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

final class AuthUseCase: UseCase {
    typealias T = AuthRepository
    
    private(set) lazy var repository: AuthRepository = createRepository()
    private(set) lazy var router = Router<AuthRepository>(repository: repository)
    
    func createRepository() -> AuthRepository {
        let dataTransferService = Application.app.services.dataTransfer
        return AuthRepository(dataTransferService: dataTransferService)
    }
}
