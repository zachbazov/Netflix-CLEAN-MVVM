//
//  NavigationViewItemViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 17/09/2022.
//

//import Foundation
//
//// MARK: - ViewModelProtocol Type
//
//private protocol ViewModelProtocol {
//    var tag: Int { get }
//    var title: String! { get }
//    var image: String! { get }
//    var isSelected: Bool { get }
//    
//    func title(for tag: Int) -> String?
////    func image(for tag: Int) -> String?
//}
//
//// MARK: - NavigationViewItemViewModel Type
//
//struct NavigationViewItemViewModel {
//    let coordinator: HomeViewCoordinator
//    
//    let tag: Int
//    var title: String!
//    var image: String!
//    var isSelected: Bool
//    
//    /// Create a navigation view item view model object.
//    /// - Parameters:
//    ///   - tag: View indicator.
//    ///   - viewModel: Coordinating view model.
//    init(tag: Int, with viewModel: HomeViewModel) {
//        self.coordinator = viewModel.coordinator!
//        self.isSelected = false
//        self.tag = tag
//        self.title = title(for: tag)
////        self.image = image(for: tag)
//    }
//}
//
//// MARK: - ViewModel Implementation
//
//extension NavigationViewItemViewModel: ViewModel {}
//
//// MARK: - ViewModelProtocol Implementation
//
//extension NavigationViewItemViewModel: ViewModelProtocol {
//    fileprivate func title(for tag: Int) -> String? {
//        guard let state = SegmentControlView.State(rawValue: tag) else { return nil }
//        switch state {
//        case .tvShows: return "TV Shows"
//        case .movies: return "Movies"
//        case .categories: return "Categories"
//        default: return nil
//        }
//    }
//    
////    fileprivate func image(for tag: Int) -> String? {
////        guard let state = NavigationView.State(rawValue: tag) else { return nil }
////        switch state {
////        case .home: return "netflix-logo-sm"
////        case .airPlay: return "airplayvideo"
////        case .search: return "magnifyingglass"
////        case .account: return "person.circle"
////        default: return nil
////        }
////    }
//}
