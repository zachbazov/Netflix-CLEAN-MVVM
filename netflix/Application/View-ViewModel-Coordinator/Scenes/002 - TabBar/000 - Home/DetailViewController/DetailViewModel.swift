//
//  DetailViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 30/09/2022.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelProtocol {
    var useCase: SeasonUseCase { get }
    var orientation: DeviceOrientation { get }
    var myList: MyList { get }
    
    var section: Section? { get }
    var media: Media? { get }
    var isRotated: Bool { get }
    
    var items: [MediaRepresentable] { get }
    
    func shouldScreenRotate()
}

// MARK: - DetailViewModel Type

final class DetailViewModel {
    var coordinator: DetailViewCoordinator?
    
    lazy var useCase: SeasonUseCase = createUseCase()
    let orientation = DeviceOrientation.shared
    let myList: MyList = Application.app.services.myList
    
    var section: Section?
    var media: Media?
    var isRotated: Bool = false {
        didSet {
            let orientation = DeviceOrientation.shared
            orientation.rotate()
        }
    }
    
    var items: [MediaRepresentable] = []
    
    deinit {
        media = nil
        section = nil
        coordinator = nil
    }
}

// MARK: - ViewModel Implementation

extension DetailViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension DetailViewModel: ViewModelProtocol {
    func shouldScreenRotate() {
        mainQueueDispatch(delayInSeconds: 1) { [weak self] in
            guard let self = self else { return }
            
            self.orientation.set(orientation: self.isRotated ? .landscapeLeft : .portrait)
        }
    }
}

// MARK: - Private Implementation

extension DetailViewModel {
    private func createUseCase() -> SeasonUseCase {
        let services = Application.app.services
        let dataTransferService = services.dataTransfer
        let repository = SeasonRepository(dataTransferService: dataTransferService)
        return SeasonUseCase(repository: repository)
    }
}
