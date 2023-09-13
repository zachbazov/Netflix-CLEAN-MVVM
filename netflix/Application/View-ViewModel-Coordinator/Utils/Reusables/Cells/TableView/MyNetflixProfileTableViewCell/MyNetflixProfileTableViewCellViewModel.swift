//
//  MyNetflixProfileTableViewCellViewModel.swift
//  netflix
//
//  Created by Developer on 10/09/2023.
//

import Foundation

// MARK: - MyNetflixProfileTableViewCellViewModel Type

struct MyNetflixProfileTableViewCellViewModel {
    let coordinator: MyNetflixCoordinator
    
    init?(with viewModel: MyNetflixViewModel) {
        guard let coordinator = viewModel.coordinator else { return nil }
        self.coordinator = coordinator
    }
    
    func getUserSelectedProfile(_ completion: @escaping (ProfileHTTPDTO.GET.Response) -> Void) {
        guard let viewModel = coordinator.viewController?.viewModel else { return }
        
        viewModel.getSelectedProfile() { response in
            guard let response = response else { return }
            
            completion(response)
        }
    }
}

// MARK: - ViewModel Implementation

extension MyNetflixProfileTableViewCellViewModel: ViewModel {}
