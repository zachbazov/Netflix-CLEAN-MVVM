//
//  MyNetflixNavigationTableHeaderViewModel.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import Foundation

struct MyNetflixNavigationTableHeaderViewModel: ViewModel {
    let coordinator: MyNetflixCoordinator
    
    let title: String
    
    init?(item: MyNetflixMenuItem, with viewModel: MyNetflixViewModel) {
        guard let coordinator = viewModel.coordinator else { return nil }
        self.coordinator = coordinator
        
        self.title = item.title
    }
}
