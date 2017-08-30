//
//  FlightDetailsViewController.swift
//  TopFlights
//
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit
import SDWebImage

class FlightDetailsViewController: UIViewController {

    @IBOutlet weak var destinationImage: UIImageView!
    @IBOutlet weak var flightDetailsContainer: UIView!
    @IBOutlet weak var flightTitle: UILabel!
    
    var controllerData : FlightModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if(controllerData != nil)
        {
            // setup view
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData(data: FlightModel) -> Void {
        controllerData = data
        // reload UI
        guard let from = controllerData?.flightFromCity else { return  }
        guard let to = controllerData?.flightToCity else { return  }
        
        let title = String.init(format: "%@ -> %@", from, to )
        
        
        flightTitle.text = title
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
