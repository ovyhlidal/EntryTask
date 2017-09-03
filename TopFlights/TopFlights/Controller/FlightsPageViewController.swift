//
//  ViewController.swift
//  TopFlights
//  Base class that represents Page view controller
//  Data for pages are requested from datasource/core data storage thru fetch result controller
//  
//
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit
import CoreData

class FlightsPageViewController: UIPageViewController {
    
    // store data due to filtering
    private var filteredData : [TravelItineraryMO]?
    
    // fetch result controller - lazy var
    lazy var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        // create sort descriptor?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"TravelItinerary")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        //        let today = Calendar.current.startOfDay(for: Date())
        //        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
        //            // Set predicate with range for start of the day and end <- get only values for today
        //            let datePredicate = NSPredicate(format: "(%@ <= dateCreated) AND (dateCreated < %@)", argumentArray: [today, nextDay])
        //            fetchRequest.predicate = datePredicate
        //        }
        
        /* This solution doesn't return distinct values thus there needs to be method for additional sorting to fullfill unique requirements.
         I can change fetch result to return dictionary instead of MO, I can select which properties to fetch. As a result I can
         get all values that have unique combinationID, but I was not successful to get to-Many property. 
         */
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataHandler.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        return fetchResultController
    }()
    
    private(set) lazy var flightDetailsViewControllers :[FlightDetailsViewController] = {
        return [   self.instantiateViewController(),
                   self.instantiateViewController(),
                   self.instantiateViewController(),
                   self.instantiateViewController(),
                   self.instantiateViewController()]
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIPageViewController
        dataSource = self
        do {
            /* fetching on main thread - this should be changed!
             Current solution is blocking UI during saving and reading data from persistence storage.
             Solution to this is use NSAsynchronousFetchRequest on PersistentContainer.newBackgroundContext() and execute.
             I was trying to make it work, but I wasn't successful. I need to read more about PersistentContainer.
             It could be achieved also another way by using parent and child context a sync changes between them.
             */
            try self.fetchResultController.performFetch()
            // check if we have some valid data
            checkDataValidity()
        } catch let error  {
            print("Error: \(error)")
        }
    }
    
    /**
     Convinience method for init of FlightDetailsViewController
     */
    private func instantiateViewController() -> FlightDetailsViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightDetailsViewController") as! FlightDetailsViewController
    }
    
    /**
     Gets fetched and filtered data, if there is not enough data requests more from api
     */
    private func checkDataValidity() {
        
        // fetch data from coredata storage
        if let fetchedData = filterData() {
            
            if (fetchedData.count >= 5 ) {
                refreshData(itinerary: fetchedData)
            } else {
                FlightsAPI.sharedInstance.getFlightsInfo(offset: fetchedData.count != 0)
            }
        }
        else {
            FlightsAPI.sharedInstance.getFlightsInfo(offset: false)
        }
        
        
    }
    
    /**
     Check if data fetch by fetch result have unique combinationID If they do, filter them based on their dateCreated
     - returns: Filtered array of objects with unique combinationID an datCreated today
     */
    
    func filterData() -> [TravelItineraryMO]? {
        
        // fetched objects - all data
        if let fetchedObjects = fetchResultController.fetchedObjects as? [TravelItineraryMO]{
            
            //let uniqueCombinationID = fetchedObjects.map { $0.combinationID! }
            let unique = fetchedObjects.unique{ $0.combinationID ?? "" }
            
            let today = Calendar.current.startOfDay(for: Date())
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                // filter objects by dateCreated - only those date from start of the day till next day
                let dateFiltered = unique.filter { today <= $0.dateCreated! && $0.dateCreated! < nextDay  }
                // if there is more than 5 results limit 
                if dateFiltered.count > 5 {
                   let slice =  dateFiltered.prefix(5)
                    return Array(slice)
                }
                
                return dateFiltered
            }
        }
        
        return nil
    }
    
    /**
     Get data enumeration and set it to detail controllers
     */
    
    func refreshData(itinerary: [TravelItineraryMO]) {
        
        // set data to controllers
        for (index, flightDetailsViewController) in flightDetailsViewControllers.enumerated() {
            let controllerData = itinerary[index]
            flightDetailsViewController.setData(data: controllerData)
        }
        
        // set first view controller
        if let startViewController = flightDetailsViewControllers.first {
            setViewControllers([startViewController],
                               direction: .forward,
                               animated: true,
                               completion: { (_) in
                                // typically hide loading indicator
            })
        }
    }
}

// MARK: - Extenstion of UIPageViewControllerDataSource
extension FlightsPageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // set view controllers
        
        guard let viewControllerIndex = flightDetailsViewControllers.index(of: viewController as! FlightDetailsViewController) else { return nil }
        
        let previousIndex = viewControllerIndex-1
        
        guard previousIndex >= 0 else {
            // no looping!
            return nil
        }
        
        guard flightDetailsViewControllers.count > previousIndex else {
            return nil
        }
        
        return flightDetailsViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = flightDetailsViewControllers.index(of: viewController as! FlightDetailsViewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex != flightDetailsViewControllers.count else {
            // no looping!
            return nil
        }
        
        guard flightDetailsViewControllers.count > nextIndex else {
            return nil
        }
        
        return flightDetailsViewControllers[nextIndex]
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return flightDetailsViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

// MARK: - Extenstion of NSFetchedResultsControllerDelegate
extension FlightsPageViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Did change content")
        self.checkDataValidity()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Will change content")
    }
}

// MARK: - Convenience array sort method for unique properties
extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}


