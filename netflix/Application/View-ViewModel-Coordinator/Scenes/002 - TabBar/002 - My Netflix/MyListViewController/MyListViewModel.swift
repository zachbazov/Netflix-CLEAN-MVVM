//
//  MyListViewModel.swift
//  netflix
//
//  Created by Developer on 11/09/2023.
//

import Foundation

// MARK: - MyListViewModel Type

final class MyListViewModel {
    var coordinator: MyListCoordinator?
    
    var media: [Media] {
        let myList = Application.app.services.myList
        let media = myList.list.toArray()
        return media
    }
}

// MARK: - ViewModel Implementation

extension MyListViewModel: ViewModel {}

// MARK: - CoordinatorAssignable Implementation

extension MyListViewModel: CoordinatorAssignable {}
