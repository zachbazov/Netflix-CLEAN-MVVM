//
//  ConfigurationTests.swift
//  netflixTests
//
//  Created by Zach Bazov on 17/02/2023.
//

import XCTest
@testable import netflix

final class ConfigurationTests: XCTestCase {
    var configuration: Configuration!
    
    override func setUp() {
        super.setUp()
        configuration = Configuration()
    }
    
    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    func testCreateAPIProperties() {
        let apiScheme = configuration.apiScheme
        let apiHost = configuration.apiHost
        
        XCTAssertNotNil(configuration)
        XCTAssertEqual(apiScheme, "https")
        XCTAssertEqual(apiHost, "netflix-rest-api.onrender.com")
    }
}
