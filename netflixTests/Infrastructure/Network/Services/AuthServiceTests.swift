//
//  AuthServiceTests.swift
//  netflixTests
//
//  Created by Zach Bazov on 17/02/2023.
//

import XCTest
@testable import netflix

final class AuthServiceTests: XCTestCase {
    var authService: AuthService!
    
    override func setUp() {
        super.setUp()
        authService = AuthService()
    }
    
    override func tearDown() {
        authService = nil
        super.tearDown()
    }
    
    func testSignIn() {
        let userDTO = UserDTO(email: "qwe@gmail.com", password: "qweqweqwe")
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        let expectation = self.expectation(description: "Expect to invoke completion block")
        authService.signIn(for: requestDTO) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(authService.user?.email, requestDTO.user.email)
        XCTAssertNotNil(authService.user?.token)
    }
    
    func testSignUp() {
        let userDTO = UserDTO(name: "test doe",
                              email: "qwe123@test.com",
                              password: "qwe123123",
                              passwordConfirm: "qwe123123")
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        let expectation = self.expectation(description: "Expect to invoke completion block")
        authService.signUp(for: requestDTO) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(authService.user?.email, requestDTO.user.email)
        XCTAssertNotNil(authService.user?.token)
    }
    
    func testResign() {
        let expectation = self.expectation(description: "Expect to invoke completion block")
        authService.resign { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSignOut() {
        let userDTO = UserDTO(email: "qwe@gmail.com", password: "qweqweqwe")
        let requestDTO = UserHTTPDTO.Request(user: userDTO)
        let expectation = self.expectation(description: "Expect to invoke sign in completion block")
        authService.signIn(for: requestDTO) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        
        let signOutExpectation = self.expectation(description: "Expect to invoke sign out completion block")
        authService.signOut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            signOutExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNil(authService.user)
    }
}
