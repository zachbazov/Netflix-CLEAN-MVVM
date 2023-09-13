//
//  ReferrableTableHeaderViewModel.swift
//  netflix
//
//  Created by Developer on 09/09/2023.
//

import Foundation

// MARK: - ReferrableTableHeaderViewModel Type

struct ReferrableTableHeaderViewModel {
    let coordinator: MyNetflixCoordinator
    
    let image: String
    let title: String
    let accessoryImage: String
    let imageBackgroundColor: Color
    let isExpanded: Bool
    let hasImage: Bool
    let hasAccessory: Bool
    
    init?(with item: MyNetflixMenuItem, with viewModel: MyNetflixViewModel) {
        guard let coordinator = viewModel.coordinator else { return nil }
        self.coordinator = coordinator
        
        self.image = item.image ?? .toBlank()
        self.title = item.title
        self.accessoryImage = "chevron.right"
        self.imageBackgroundColor = item.color ?? Color(color: .clear)
        self.isExpanded = item.isExpanded ?? false
        self.hasImage = item.hasImage
        self.hasAccessory = item.hasAccessory
    }
}

// MARK: - ViewModel Implementation

extension ReferrableTableHeaderViewModel: ViewModel {}
