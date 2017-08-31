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
    // paging There seems to be problem with malformed URL in _next and _previous -> URL should be replaced by default URL and use HTTPS - decided not to use paging.
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

/**
 Model that represents flight object its mapped to response flights.data, its based on FlightInfo. It adds some additional fields.
 */
class FlightModel: FlightInfo {
    
    var flyDuration : String?
    var flightToCountry: String?
    var flightFromCountry: String?
    var price: Int?
    var currency: String?
    var flightNumber: Int?
    var distance: Double?
    var flightsCount: Int?
    // ids for images
    var routes: [Route]?
        
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        flightFromCountry   <- map["countryFrom.name"]
        flightToCountry     <- map["countryTo.name"]
        price               <- map["price"]
        currency = "EUR"
        distance            <- map["distance"]// assume distance in Km
        flightsCount        <- map["pnr_count"]
        flyDuration         <- map["fly_duration"]
        routes              <- map["route"]
    }
}

/**
 Model that represents parts of one route, information about particular flights - its based on FlightInfo
 */
class Route: FlightInfo {

    var flightNumber: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        flightNumber        <- map["flight_no"]
    }
}

/**
 Base model class for flights
 */
class FlightInfo: Mappable {
    
    var flightFromCity : String?
    var flightToCity : String?
    var combinationID : Int?
    var flightFromCityID: String?
    var flightToCityID: String?
    var departureTimeUTC: Double?
    var arrivalTimeUTC: Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        flightFromCity      <- map["cityFrom"]
        flightToCity        <- map["cityTo"]
        combinationID       <- map["id"]
        departureTimeUTC    <- map["dTimeUTC"]
        arrivalTimeUTC      <- map["aTimeUTC"]
        // ids for images
        flightFromCityID    <- map["mapIdfrom"]
        flightToCityID      <- map["mapIdto"]
    }
}


