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
    
    
    // fetch result controller - lazy var
    lazy var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        // create sort descriptor?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"TravelItinerary")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        let today = Calendar.current.startOfDay(for: Date())
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            // Set predicate with range for start of the day and end <- get only values for today
            let datePredicate = NSPredicate(format: "(%@ <= dateCreated) AND (dateCreated < %@)", argumentArray: [today, nextDay])
            fetchRequest.predicate = datePredicate
        }
        
        /* This solution doesn't return distinct values thus there needs to be method for additional sorting to fullfill unique requirements.
         I can change fetch result to return dictionary instead of MO, I can select which properties to fetch. As a result I can
         get all values that have unique combinationID, but I was not successful to get to-Many property. 
         */
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataHandler.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
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
    
    //
    private func checkDataValidity() {
        // fetch data from coredata storage
        if let fetchedObjects = fetchResultController.fetchedObjects {
            if (fetchedObjects.count == 5) {
                refreshData()
            } else {
                FlightsAPI.sharedInstance.getFlightsInfo(offset: fetchedObjects.count != 0)
            }
        }
        else {
            FlightsAPI.sharedInstance.getFlightsInfo(offset: false)
        }
    }
    
    /**
     Get data enumeration and set it to detail controllers
     */
    
    func refreshData() {
        
        // set data
        for (index, flightDetailsViewController) in flightDetailsViewControllers.enumerated() {
            if let controllerData = fetchResultController.object(at: IndexPath.init(row: index, section: 0)) as? TravelItineraryMO{
                flightDetailsViewController.setData(data: controllerData)
            }
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
        self.refreshData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Will change content")
    }
}

