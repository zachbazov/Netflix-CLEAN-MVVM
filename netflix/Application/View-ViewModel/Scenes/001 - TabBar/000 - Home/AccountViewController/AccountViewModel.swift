//
//  AccountViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 10/03/2023.
//

import Foundation

// MARK: - ViewModelProtocol Type

private protocol ViewModelInput {
    
}

private protocol ViewModelOutput {
    
}

private typealias ViewModelProtocol = ViewModelInput & ViewModelOutput

// MARK: - AccountViewModel Type

final class AccountViewModel {
    var coordinator: AccountViewCoordinator?
    
    lazy var menuItems: [AccountMenuItem] = createMenuItems()
    private(set) lazy var profileItems: [ProfileItem] = createProfileItems()
    private(set) lazy var addProfileItem: ProfileItem = createAddProfileItem()
    
    private func createMenuItems() -> [AccountMenuItem] {
        let notifications = AccountMenuItem(image: "bell", title: "Notifications", options: ["1", "2", "3"], isExpanded: false)
        let myList = AccountMenuItem(image: "checkmark", title: "My List")
        let appSettings = AccountMenuItem(image: "gearshape", title: "App Settings")
        let account = AccountMenuItem(image: "person", title: "Account")
        let help = AccountMenuItem(image: "questionmark.circle", title: "Help")
        let items = [notifications, myList, appSettings, account, help]
        return items
    }
    
    private func createProfileItems() -> [ProfileItem] {
        let profile1 = ProfileItem(image: "av-light-yellow", name: "Zach")
//        let profile2 = ProfileItem(image: "av-dark-green", name: "LeBron")
//        let profile3 = ProfileItem(image: "av-dark-red", name: "John")
        let items = [profile1, addProfileItem]
        return items
    }
    
    private func createAddProfileItem() -> ProfileItem {
        return ProfileItem(image: "plus", name: "Add Profile")
    }
}

// MARK: - ViewModel Implementation

extension AccountViewModel: ViewModel {}

// MARK: - ViewModelProtocol Implementation

extension AccountViewModel: ViewModelProtocol {}
