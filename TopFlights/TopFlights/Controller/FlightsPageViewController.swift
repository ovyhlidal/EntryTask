//
//  ViewController.swift
//  TopFlights
//  Base class that represents Page view controller
//  Data for pages are requested from datasource/core data storage thru fetch result controller
//  Each page should have title, image and basic information about promoted flights
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dataSource = self
        delegate = self
        
        do {
            try self.fetchResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchResultController.fetchedObjects?.count))")
            // we some data
            checkDataValidity()
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func instantiateViewController() -> FlightDetailsViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightDetailsViewController") as! FlightDetailsViewController
    }
    
    func refreshControllerData(data: [TravelItineraryMO]) -> Void {
       
        flightDetailsViewControllers[0].setData(data:data[0])
        flightDetailsViewControllers[1].setData(data:data[1])
        flightDetailsViewControllers[2].setData(data:data[2])
        flightDetailsViewControllers[3].setData(data:data[3])
        flightDetailsViewControllers[4].setData(data:data[4])
        
    }
    
    // TODO: add throw
    func checkDataValidity() {
        // fetch data from coredata storage
        guard (fetchResultController.fetchedObjects != nil && fetchResultController.fetchedObjects?.count != 0) else {
          // no data -> get some new
            FlightsAPI.init().getFlightsInfo()
            return
        }
        
        // check if data are for today?
        
        // no data or old data -> download new data
        
        // once donwloaded notify controller to refresh
        
        refreshData()
        
    }
    

    func refreshData() {
        //  DispatchQueue.main.async {
        
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
                                //
            })
        }
    }
}

/**
 Extenstion of UIPageViewControllerDataSource
*/

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

/**
 Extenstion of UIPageViewControllerDelegate
 */
extension FlightsPageViewController : UIPageViewControllerDelegate {
    
}

/**
 Extenstion of NSFetchedResultsControllerDelegate
 */
extension FlightsPageViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Did change content")
        self.refreshData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         print("Will change content")
    }
}

