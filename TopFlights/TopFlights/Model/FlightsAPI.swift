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
import SwiftyJSON
import CoreData


/**
 This delegate is not used. 
 */
protocol FlightsLoadedDelegate {
    /**
     Delegate method that is called when datasource finishes preparation of data for controller
     - paramethers:
     - data: Actual data for controllers that should be displayed
     */
    func flighInformationLoade(data: [TravelItineraryMO])
    
}

/**
 Struct that holds all constants used in search query
 */
struct FlightsQueryConstants {
    
    static let baseURL = "https://api.skypicker.com/flights"
    static let version = "v"
    // dates - mandatory params
    static let dateFrom = "dateFrom"
    static let dateTo = "dateTo"
    // for result paging
    static let ofset = "ofset"
    //flyFrom - mandatory
    static let flyFrom = "flyFrom"
    static let flyFromBrno = "49.17-16.56-450km"
    static let flyTo = "to"
    static let anyWhere = "anywhere"
    static let limit = "limit"
    
    // following parameters will remain hardcoded for the purpose of this simple app.
    static let sort = "sort"
    static let sortByPopularity = "popularity"
    static let passengers = "passengers"
    static let flightTypes = "typeFlight"
    static let oneWayFlight = "oneway"
    
    static let currency = "curr"
    static let currencyEUR = "EUR"
    static let oneForCity = "oneforcity"
    static let partner = "partner"
    static let partnetPicky = "picky"
    static let partnerMarket = "partner_market"
    static let partnerMarketUS = "us"
    static let locale = "locale"
    static let localeEN = "en"
    
    // image API
    static let imageAPI = "https://images.kiwi.com/photos/600/%@.jpg"
}
/**
 FlightsDatasource is responsible for preparing all data necessary for controllers. It handles HTTP requests, mapping received data and filtering.
 */

class FlightsAPI: NSObject {
    
    /**
     Instead of delegate use callback function
     */
    var onComplete:((_ data : [TravelItineraryMO]) -> ())?
    
    
    /**
     Public method for refresh data. It sends HTTPS GET request with predefined parameters.
     */
    
    func getFlightsInfo() -> Void {
        // obtain current date
        guard let today = getFormatedToday()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Current date was not obtained!")
            return   }
        
        guard let nextDay = getFormaterNextDay()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Next day date was not obtained!")
            return  }
        
        let parameters = createParams(dateFrom: today, dateTo: nextDay)
        
        print(parameters.description)
        
        // make request with base URL, method GET, Parameters, default encoding,  headers could be nil
        Alamofire.request(FlightsQueryConstants.baseURL,
                          method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil)
            .validate(statusCode: 200...300)
            .responseJSON { response in
                if let value = response.result.value as? [String: Any] {
                    print("Dictionary received, lets pass it to core data!")
                    CoreDataHandler.sharedInstance.saveToCoreDataWithDictionary(dictionary: value)
                }
        }
    }
    
    /**
     Returns array of query parameters
     - parameters:
     - dateFrom: define date from flights will be searched
     - dateTo: define date to flight will be searched
     */
    fileprivate func createParams(dateFrom:String, dateTo:String ) -> Parameters {
        // Create array of parameters - version, flyFr
        let parameters : Parameters = [FlightsQueryConstants.version : "2",
                                       FlightsQueryConstants.flyFrom : FlightsQueryConstants.flyFromBrno,
                                       FlightsQueryConstants.dateFrom : dateFrom,
                                       FlightsQueryConstants.dateTo : dateTo,
                                       FlightsQueryConstants.sort : FlightsQueryConstants.sortByPopularity,
                                       FlightsQueryConstants.flyTo : FlightsQueryConstants.anyWhere,
                                       FlightsQueryConstants.locale : FlightsQueryConstants.localeEN,
                                       FlightsQueryConstants.passengers : "1",
                                       FlightsQueryConstants.oneForCity : "1",
                                       FlightsQueryConstants.currency : FlightsQueryConstants.currencyEUR,
                                       FlightsQueryConstants.partner : FlightsQueryConstants.partnetPicky,
                                       FlightsQueryConstants.partnerMarket : FlightsQueryConstants.partnerMarketUS,
                                       FlightsQueryConstants.limit : "10"]
        return parameters
    }
    
    fileprivate func getFormatedDated(date : Date) -> String {
        let formatter = DateFormatter()
        // required format: 29/09/2017
        formatter.dateFormat = "dd/MM/YYYY"
        
        return formatter.string(from: date)
    }
    
    fileprivate func getFormaterNextDay() -> String? {
        
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return nil
        }
        return getFormatedDated(date: nextDay)
    }
    
    fileprivate func getFormatedToday() -> String? {
        return getFormatedDated(date: Date())
    }
}
