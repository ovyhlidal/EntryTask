//
//  ViewController.swift
//  TopFlights
//  Base class that represents Page view controller
//  Data for pages are requested from datasource.
//  Each page should have title, image and basic information about promoted flights
//
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit

class FlightsPageViewController: UIPageViewController {
    
    
    private(set) lazy var mockViewControllers :[FlightDetailsViewController] = {
        return [   self.instantiateViewController(),
                   self.instantiateViewController(),
                   self.instantiateViewController(),
                   self.instantiateViewController(),
                   self.instantiateViewController()]
    }()
    
    
    
    let datasource = FlightsDatasource()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dataSource = self
        delegate = self
        
        if let startViewController = mockViewControllers.first {
            setViewControllers([startViewController],
                               direction: .forward,
                               animated: true,
                               completion: { (_) in
                                //
            })
        }
        
        datasource.onComplete = { data in
            self.refreshControllerData(data: data)
        }
        
        datasource.refreshFlightsInfo()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func instantiateViewController() -> FlightDetailsViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightDetailsViewController") as! FlightDetailsViewController
    }
    
    func refreshControllerData(data: [FlightModel]) -> Void {
       
        mockViewControllers[0].setData(data:data[0])
        mockViewControllers[1].setData(data:data[1])
        mockViewControllers[2].setData(data:data[2])
        mockViewControllers[3].setData(data:data[3])
        mockViewControllers[4].setData(data:data[4])
        
    }
}

extension FlightsPageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // set view controllers
        
        guard let viewControllerIndex = mockViewControllers.index(of: viewController as! FlightDetailsViewController) else { return nil }
        
        let previousIndex = viewControllerIndex-1
        
        guard previousIndex >= 0 else {
            //loop through
            return nil
        }
        
        guard mockViewControllers.count > previousIndex else {
            return nil
        }
        
        return mockViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //
        guard let viewControllerIndex = mockViewControllers.index(of: viewController as! FlightDetailsViewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex != mockViewControllers.count else {
            // go to first
            return nil
        }
        
        guard mockViewControllers.count > nextIndex else {
            return nil
        }
        
        return mockViewControllers[nextIndex]
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return mockViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension FlightsPageViewController : UIPageViewControllerDelegate {
    
}

