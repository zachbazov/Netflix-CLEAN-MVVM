//
//  StoresTests.swift
//  netflixTests
//
//  Created by Zach Bazov on 17/02/2023.
//

import XCTest
@testable import netflix

final class StoresTests: XCTestCase {
    var stores: Stores!
    
    override func setUp() {
        super.setUp()
        let services = Services()
        stores = Stores(services: services)
    }
    
    override func tearDown() {
        stores = nil
        super.tearDown()
    }
    
    func testCreateStoresService() {
        XCTAssertNotNil(stores)
    }
}
