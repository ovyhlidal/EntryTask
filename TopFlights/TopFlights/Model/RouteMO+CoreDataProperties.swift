//
//  RouteMO+CoreDataProperties.swift
//  TopFlights
//
//  Created by OndrejVyhlidal on 01/09/2017.
//  Copyright © 2017 ID. All rights reserved.
//
//

import Foundation
import CoreData


extension RouteMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RouteMO> {
        return NSFetchRequest<RouteMO>(entityName: "Route")
    }

    @NSManaged public var flightNumber: String?

}
