//
//  CoreDataHandler.swift
//  TopFlights
//  This class is singleton used for handling all Core Data operations - moved methods from AppDelegate to this class.
//
//  Created by OndrejVyhlidal on 31/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit
import CoreData


class CoreDataHandler : NSObject{
    
    //Singleton
    static let sharedInstance = CoreDataHandler()
    private override init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TopFlights")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /**
     Inserts new MO object, mapps all fields
     */
    
    private func createTravelItineraryFrom(dictionary: [String:Any]) -> NSManagedObject? {
        // Due to using only one context saving of data is on main thread thus blocking UI, this should be changed.
        let context = persistentContainer.viewContext
        
        if let travelItineraryEntity = NSEntityDescription.insertNewObject(forEntityName: "TravelItinerary", into: context) as? TravelItineraryMO {
            
            if let cityFrom = dictionary["cityFrom"] as? String {
                travelItineraryEntity.flightFromCity = cityFrom
            }
            
            if let cityTo = dictionary["cityTo"] as? String {
                travelItineraryEntity.flightToCity = cityTo
            }
            
            if let cityFromID = dictionary["mapIdfrom"] as? String {
                travelItineraryEntity.flightFromCityID = cityFromID
            }
            
            if let cityToID = dictionary["mapIdto"] as? String {
                travelItineraryEntity.flightToCityID = cityToID
            }
            
            //country from and country to are dictionaries
            if let countryFrom =  dictionary["countryFrom"] as? [String: Any] {
                travelItineraryEntity.flightFromCountry = countryFrom["name"] as? String
            }
            
            if let countryTo =  dictionary["countryTo"] as? [String: Any] {
                travelItineraryEntity.flightToCountry = countryTo["name"] as? String
            }
            
            if let flightCount = dictionary["pnr_count"] as? Int16 {
                travelItineraryEntity.flightsCount = flightCount
            }
            
            travelItineraryEntity.combinationID = dictionary["id"] as? String
            
            if let departureTimeUTC = dictionary["dTimeUTC"] as? Double {
                travelItineraryEntity.departureTimeUTC = departureTimeUTC
            }
            
            if let arrivalTimeUTC = dictionary["aTimeUTC"] as? Double {
                travelItineraryEntity.arrivalTimeUTC = arrivalTimeUTC
            }
            
            if let price = dictionary["price"] as? Double {
                travelItineraryEntity.price = price
            }
            
            travelItineraryEntity.currency = "EUR" // Hardcoded value. Can be obtained thru API
            
            
            let date =  Calendar.current.startOfDay(for: Date())
            
            travelItineraryEntity.dateCreated = date
            
            travelItineraryEntity.flyDuration = dictionary["fly_duration"] as? String
            
            if let routes = dictionary["route"] as? [AnyObject] {
                
                for route in routes {
                    
                    if let routeMO = NSEntityDescription.insertNewObject(forEntityName: "Route", into: context) as? RouteMO {
                        routeMO.flightFromCity = route["cityFrom"] as? String
                        routeMO.flightToCity = route["cityTo"] as? String
                        routeMO.flightFromCityID = route["mapIdfrom"] as? String
                        routeMO.flightToCityID = route["mapIdto"] as? String
                        routeMO.flightNumber = route["flight_no"] as? String
                        
                        travelItineraryEntity.addToRoute(routeMO)
                    }
                }
            }
            return travelItineraryEntity
        }
        return nil
    }
    
    public func saveToCoreDataWithDictionary(dictionary: [String:Any]) {
        saveObjectsFromResponse(dictionary: dictionary)
    }
    
    private func saveObjectsFromResponse(dictionary: [String: Any]) {
        
        var flightItineraryObjects = [NSManagedObject]()
        // currency can be obtained here -> before we dive in to "data" or use conversion
        // data is array
        if let data = dictionary["data"] as? [Any] {
            // array of created objects
            
            for flightInfor in data {
                // cast object to dictionary
                if let flightDictionary = flightInfor as? [String:Any] {
                    if let  itinerary = createTravelItineraryFrom(dictionary: flightDictionary) {
                        flightItineraryObjects.append( itinerary )
                    }
                }
            }
        }
        
        // save context
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print("Objects not sucessfully saved, error: \(error)")
        }
        
    }
    
}
