//
//  Theme.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

// MARK: - ThemeControl Type

private protocol ThemeControl {
    static var currentTheme: Theme.ThemeType { get }
    static var barButtonTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    static var navigationBarTitleTextAttributes: [NSAttributedString.Key: Any] { get }
    static var navigationBarBackgroundColor: UIColor { get }
    static var navigationBarTintColor: UIColor { get }
    static var tintColor: UIColor { get }
    
    static func switchTo(theme: Theme.ThemeType)
    static func applyAppearance(for navigationController: UINavigationController?)
}

// MARK: - ThemeUpdatable Type

protocol ThemeUpdatable {
    func updateWithTheme()
}

// MARK: - Theme Type

final class Theme {
    enum ThemeType {
        case light
        case dark
    }
    
    static var currentTheme: ThemeType = .dark
    
    static var barButtonTitleTextAttributes: [NSAttributedString.Key: Any] {
        switch currentTheme {
        case .dark:
            return [.foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 16.0, weight: .heavy)]
        case .light:
            return [.foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 16.0, weight: .heavy)]
        }
    }
    
    static var navigationBarTitleTextAttributes: [NSAttributedString.Key: Any] {
        switch currentTheme {
        case .dark:
            return [.foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 17.0, weight: .heavy)]
        case .light:
            return [.foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 17.0, weight: .heavy)]
        }
    }
    
    static var navigationBarBackgroundColor: UIColor {
        switch currentTheme {
        case .dark:
            return UIColor.black
        case .light:
            return UIColor.white
        }
    }
    
    static var navigationBarTintColor: UIColor {
        switch currentTheme {
        case .dark:
            return UIColor.white
        case .light:
            return UIColor.black
        }
    }
    
    static var tintColor: UIColor {
        switch currentTheme {
        case .dark:
            return .white
        case .light:
            return .black
        }
    }
    
    static var backgroundColor: UIColor {
        switch currentTheme {
        case .dark:
            return UIColor.black
        case .light:
            return UIColor.white
        }
    }
    
    static var preferredStatusBarStyle: UIStatusBarStyle {
        switch currentTheme {
        case .dark:
            return .lightContent
        case .light:
            return .darkContent
        }
    }
}

// MARK: - ThemeControl Implementation

extension Theme: ThemeControl {
    static func switchTo(theme: ThemeType) {
        currentTheme = theme
    }
    
    static func applyAppearance(for navigationController: UINavigationController? = nil) {
        if #available(iOS 15, *) {
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.configureWithDefault(for: .plain)
            barButtonItemAppearance.normal.titleTextAttributes = barButtonTitleTextAttributes
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.titleTextAttributes = navigationBarTitleTextAttributes
            navigationBarAppearance.backgroundColor = navigationBarBackgroundColor
            navigationBarAppearance.buttonAppearance = barButtonItemAppearance
            
            if let navigationController = navigationController {
                navigationController.navigationBar.tintColor = navigationBarTintColor
                navigationController.navigationBar.standardAppearance = navigationBarAppearance
                navigationController.navigationBar.compactAppearance = navigationBarAppearance
                navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
                
                return
            }
            
            UINavigationBar.appearance().barTintColor = navigationBarTintColor
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        } else {
            UINavigationBar.appearance().barTintColor = navigationBarTintColor
            UINavigationBar.appearance().tintColor = tintColor
            UINavigationBar.appearance().titleTextAttributes = navigationBarTitleTextAttributes
        }
    }
    
    static func applyUserProfileAppearance() {
        if #available(iOS 15, *) {
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.configureWithDefault(for: .plain)
            barButtonItemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16, weight: .heavy)]
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 18.0, weight: .bold)]
            navigationBarAppearance.backgroundColor = .hexColor("#161616")
            navigationBarAppearance.buttonAppearance = barButtonItemAppearance
            
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        } else {
            UINavigationBar.appearance().barTintColor = UIColor.black.withAlphaComponent(0.75)
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
        }
    }
}
