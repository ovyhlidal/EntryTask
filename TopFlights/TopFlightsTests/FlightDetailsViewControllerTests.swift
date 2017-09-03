//
//  FlightDetailsViewControllerTests.swift
//  TopFlightsTests
//
//  Created by OndrejVyhlidal on 02/09/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import XCTest
import CoreData
@testable import TopFlights

class FlightDetailsViewControllerTests: XCTestCase {
    
    let viewController = FlightDetailsViewController()
    
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
    
    func testSetControllerData() {
        let managedObjectContext = setUpInMemoryManagedObjectContext()
        if let mEntity = NSEntityDescription.insertNewObject(forEntityName: "TravelItinerary", into: managedObjectContext) as? TravelItineraryMO {
            
            // mock object with test data
            
            mEntity.flightFromCity = "Brno"
            mEntity.flightToCity = "Praha"
            mEntity.currency = "EUR"
            mEntity.price = 100.0
            mEntity.flightFromCountry = "Czech Republic"
            mEntity.flightToCountry = "Czech Republic"
            mEntity.dateCreated = Date() as NSDate
            mEntity.distance = 250.0
            mEntity.departureTimeUTC = 1504561200.0
            mEntity.arrivalTimeUTC = 1504561200.0
            mEntity.flyDuration = "SoLooong"
            mEntity.flightToCityID = "prague_cz"
            mEntity.flightFromCityID = "brno_cz"
            // set object to controller
            viewController.setData(data: mEntity)
            
            // invoke refresh
            XCTAssertNotNil(viewController.controllerData, "Controller data should not be nil")
        }
    }
    
    // in order to test core data we need to have a way to create in memory objects
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
}
