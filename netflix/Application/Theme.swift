//
//  Theme.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - ThemingBehavior Type

private protocol ThemingBehavior {
    static func `default`()
    static func dark()
}

// MARK: - Theme Type

final class Theme {}

// MARK: - ThemingBehavior Implementation

extension Theme: ThemingBehavior {
    /// Setup application's default appearance.
    static func `default`() {
        if #available(iOS 15, *) {
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.configureWithDefault(for: .plain)
            barButtonItemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16, weight: .heavy)]
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
            navigationBarAppearance.backgroundColor = .black.withAlphaComponent(0.75)
            navigationBarAppearance.buttonAppearance = barButtonItemAppearance
            
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        } else {
            UINavigationBar.appearance().barTintColor = .black.withAlphaComponent(0.75)
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        }
    }
    /// Setup application's dark appearance.
    static func dark() {
        if #available(iOS 15, *) {
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.configureWithDefault(for: .plain)
            barButtonItemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16, weight: .heavy)]
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
            navigationBarAppearance.backgroundColor = .black
            navigationBarAppearance.buttonAppearance = barButtonItemAppearance
            
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        } else {
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        }
    }
}