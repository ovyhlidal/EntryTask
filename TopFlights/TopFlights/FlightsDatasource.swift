//
//  FlightsDatasource.swift
//  TopFlights
//
//  Class responsible for handling network communication thru Alamofire.
//  It also helps with query creation.
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit
import Alamofire

protocol FlightsLoadedDelegate {
    
}

struct FlightsQueryConstants {
    let limit = "5"
    
}

class FlightsDatasource: NSObject {

    /*https://api.skypicker.com/flights?v=2&sort=popularity&asc=0&locale=en&daysInDestinationFrom=&daysInDestinationTo=&affilid=&children=0&infants=0&flyFrom=49.2-16.61-250km&to=anywhere&featureName=aggregateResults&dateFrom=29/09/2017&dateTo=30/09/2017&typeFlight=oneway&returnFrom=&returnTo=&one_per_date=0&oneforcity=1&wait_for_refresh=0&adults=1&limit=5
     *
     *
     */
}
