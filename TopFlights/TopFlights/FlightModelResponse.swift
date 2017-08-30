//
//  FlightModel.swift
//  TopFlights
//
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit
import ObjectMapper

class FlightModelResponse: Mappable {
    // information about query
    var numberOfResults: Int?
    // paging There seems to be problem with malformed URL in _next and _previous -> URL should be replaced by default URL and use HTTPS
    var previousQuery: String?
    var nextQuery: String?
    // information about flights
    var flightsInfo:[FlightModel]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        previousQuery       <- map["_previous"]
        nextQuery           <- map["_next"]
        flightsInfo         <- map["data"]
    }
    
}

class FlightModel: Mappable {
    
    var flyDuration : String?
    var flightFromCity: String?
    var flightToCity: String?
    var flightToCountry: String?
    var flightFromCountry: String?
    var combinationID : Int?
    var price: Int?
    var currency: String?
    var departureTimeUTC: Int?
    var arrivalTimeUTC: Int?
    var flightNumber: Int?
    var distance: Double?
    var flightsCount: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        flyDuration         <- map["fly_duration"]
        flightFromCity      <- map["cityFrom"]
        flightToCity        <- map["cityTo"]
        flightFromCountry   <- map["countryFrom.name"]
        flightToCountry     <- map["countryTo.name"]
        combinationID       <- map["id"]// route objects ids merged together
        price               <- map["price"]
        //currency            <- map[""] EUR is default
        departureTimeUTC    <- map["dTimeUTC"]
        arrivalTimeUTC      <- map["aTimeUTC"]
        // flightNumber        <- map[""]
        distance            <- map["distance"]// assume distance in Km
        flightsCount        <- map["pnr_count"]
    }
    
}
