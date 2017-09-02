//
//  FlightMO+CoreDataProperties.swift
//  TopFlights
//
//  Created by OndrejVyhlidal on 01/09/2017.
//  Copyright © 2017 ID. All rights reserved.
//
//

import Foundation
import CoreData


extension FlightMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlightMO> {
        return NSFetchRequest<FlightMO>(entityName: "Flight")
    }

    @NSManaged public var arrivalTimeUTC: Double
    @NSManaged public var combinationID: String?
    @NSManaged public var departureTimeUTC: Double
    @NSManaged public var flightFromCity: String?
    @NSManaged public var flightFromCityID: String?
    @NSManaged public var flightToCityID: String?
    @NSManaged public var fligltToCity: String?

}
