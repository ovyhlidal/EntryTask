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
    
    private(set) lazy var mockViewControllers :[UIViewController] = {
        return [ UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightDetailsViewController"),
                 UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightDetailsViewController"),
                 self.instantiateViewController(),
                 self.instantiateViewController()]
    }()

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func instantiateViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightDetailsViewController")
    }


}

extension FlightsPageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // set view controllers
        
        guard let viewControllerIndex = mockViewControllers.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex-1
        
        guard previousIndex >= 0 else {
            //loop through
            return mockViewControllers.last
        }
        
        guard mockViewControllers.count > previousIndex else {
            return nil
        }
        
        return mockViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
       //
         guard let viewControllerIndex = mockViewControllers.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex != mockViewControllers.count else {
            // go to first
            return mockViewControllers.first
        }
        
        guard mockViewControllers.count > nextIndex else {
            return nil
        }
        
        return mockViewControllers[nextIndex]
    
    }
}

extension FlightsPageViewController : UIPageViewControllerDelegate {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return mockViewControllers.count
    }
    
}

