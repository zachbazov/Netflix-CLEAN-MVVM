//
//  CoordinatorTests.swift
//  netflixTests
//
//  Created by Zach Bazov on 17/02/2023.
//

import XCTest
@testable import netflix

final class CoordinatorTests: XCTestCase {
    var application: Application!
    var coordinator: RootCoordinator!
    
    override func setUp() {
        super.setUp()
        application = Application.app
        coordinator = application.dependencies.coordinator
    }
    
    override func tearDown() {
        coordinator = nil
        application = nil
        super.tearDown()
    }
    
    func testCreateAuthController() {
        let window = UIWindow()
        coordinator.window = window
        
        coordinator.createAuthController()
        
        XCTAssertTrue(window.rootViewController is AuthController)
        XCTAssertNotNil(coordinator.authCoordinator)
    }
    
    func testCreateTabBarController() {
        let window = UIWindow()
        coordinator.window = window
        
        coordinator.createTabBarController()
        
        XCTAssertTrue(window.rootViewController is TabBarController)
        XCTAssertNotNil(coordinator.tabCoordinator)
    }
}
