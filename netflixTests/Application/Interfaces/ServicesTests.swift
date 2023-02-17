//
//  ServicesTests.swift
//  netflixTests
//
//  Created by Zach Bazov on 17/02/2023.
//

import XCTest
@testable import netflix

final class ServicesTests: XCTestCase {
    var services: Services!
    
    override func setUp() {
        super.setUp()
        services = Services()
    }
    
    override func tearDown() {
        services = nil
        super.tearDown()
    }
    
    func testCreateDataTransferService() {
        let dataTransferService = services.createDataTransferService()
        
        XCTAssertNotNil(dataTransferService)
        XCTAssertEqual(dataTransferService.networkService.config.baseURL.absoluteString, "https://netflix-rest-api.onrender.com")
    }
}
