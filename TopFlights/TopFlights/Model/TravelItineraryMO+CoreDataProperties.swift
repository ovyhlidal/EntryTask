//
//  TravelItineraryMO+CoreDataProperties.swift
//  TopFlights
//
//  Created by OndrejVyhlidal on 02/09/2017.
//  Copyright © 2017 ID. All rights reserved.
//
//

import Foundation
import CoreData


extension TravelItineraryMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TravelItineraryMO> {
        return NSFetchRequest<TravelItineraryMO>(entityName: "TravelItinerary")
    }

    @NSManaged public var currency: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var distance: Double
    @NSManaged public var flightFromCountry: String?
    @NSManaged public var flightsCount: Int16
    @NSManaged public var flightToCountry: String?
    @NSManaged public var flyDuration: String?
    @NSManaged public var price: Double
    @NSManaged public var route: NSOrderedSet?

}

// MARK: Generated accessors for route
extension TravelItineraryMO {

    @objc(insertObject:inRouteAtIndex:)
    @NSManaged public func insertIntoRoute(_ value: RouteMO, at idx: Int)

    @objc(removeObjectFromRouteAtIndex:)
    @NSManaged public func removeFromRoute(at idx: Int)

    @objc(insertRoute:atIndexes:)
    @NSManaged public func insertIntoRoute(_ values: [RouteMO], at indexes: NSIndexSet)

    @objc(removeRouteAtIndexes:)
    @NSManaged public func removeFromRoute(at indexes: NSIndexSet)

    @objc(replaceObjectInRouteAtIndex:withObject:)
    @NSManaged public func replaceRoute(at idx: Int, with value: RouteMO)

    @objc(replaceRouteAtIndexes:withRoute:)
    @NSManaged public func replaceRoute(at indexes: NSIndexSet, with values: [RouteMO])

    @objc(addRouteObject:)
    @NSManaged public func addToRoute(_ value: RouteMO)

    @objc(removeRouteObject:)
    @NSManaged public func removeFromRoute(_ value: RouteMO)

    @objc(addRoute:)
    @NSManaged public func addToRoute(_ values: NSOrderedSet)

    @objc(removeRoute:)
    @NSManaged public func removeFromRoute(_ values: NSOrderedSet)

}
