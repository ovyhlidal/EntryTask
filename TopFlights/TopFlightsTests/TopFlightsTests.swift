//
//  TopFlightsTests.swift
//  TopFlightsTests
//
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import XCTest
@testable import TopFlights

class TopFlightsTests: XCTestCase {
    
    let viewController = FlightsPageViewController()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInitViewControllers() {
        
        let vcArray = viewController.flightDetailsViewControllers
       
        // assert that view controller lazy property is initialized when acces with right number of controllers
        XCTAssertTrue(vcArray.count == 5 )
    }
    
}
