//
//  FlightsDatasource.swift
//  TopFlights
//
//  Class responsible for handling network communication thru Alamofire.
//  Contains query constants.
//  Created by OndrejVyhlidal on 29/08/2017.
//  Copyright © 2017 ID. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

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
    static let offset = "offset"
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
    static let baseOffsetValue = 5
    
    // image API
    static let imageAPI = "https://images.kiwi.com/photos/600/%@.jpg"
}
/**
 FlightsAPI is responsible for API calls. It handles HTTP requests, mapping received data to Dictionary and then calls
 CoreDataHandler for further data processing.
 */

class FlightsAPI: NSObject {
    
    // Alamofire session manager
    var sessionManager: SessionManager!
    
    // Used for paging
    var lastOffset: Int?
    
    static let sharedInstance = FlightsAPI()
    private override init() {
        // configure alamofire session manager to perform operations on background - non blocking UI
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.topFlights.app.background")
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    /**
     Public method for refresh data. It sends HTTPS GET request with predefined parameters.
     */
    
    func getFlightsInfo(offset:Bool) -> Void {
        
        // download new data -> offset set to 0
        lastOffset = offset ? lastOffset : 0
        
        // obtain current date
        guard let today = getFormatedToday()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Current date was not obtained!")
            return   }
        
        guard let nextDay = getFormaterTomorrow()?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Next day date was not obtained!")
            return  }
        
        // convert optional int to str
        var strOffset = ""
        if let v = lastOffset {
            strOffset =  "\(v)"
        }
        
        // array of params
        let parameters = createParams(dateFrom: today, dateTo: nextDay, offset:strOffset )
        
        print(parameters.description)
        
        // make request with base URL, method GET, Parameters, default encoding,  headers could be nil
        
        sessionManager.request(FlightsQueryConstants.baseURL,
                               method: .get,
                               parameters: parameters,
                               encoding: URLEncoding.default,
                               headers: nil)
            .validate(statusCode: 200...300) // response code validation
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    // process received data
                    if let value = response.result.value as? [String: Any] {
                        print("Dictionary received, lets pass it to core data!")
                        if (value["_next"] as? String) != nil {
                            
                            //FIXME: There seems to be problem in response in _next -> there is wrong URL -> store just offset number
                            if var lo = self.lastOffset {
                                lo += FlightsQueryConstants.baseOffsetValue
                                self.lastOffset = lo
                            }
                            
                        }
                        // create objects in context and store
                        CoreDataHandler.sharedInstance.saveToCoreDataWithDictionary(dictionary: value)
                    }
                    
                case .failure(let error):
                    // at least print error message
                    // notify user about problems
                    print(error)
                }
        }
    }
    
    /**
     Returns array of query parameters
     - parameters:
     - dateFrom: define date from flights will be searched
     - dateTo: define date to flight will be searched
     */
    fileprivate func createParams(dateFrom:String, dateTo:String, offset:String) -> Parameters {
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
                                       FlightsQueryConstants.limit : "5",
                                       FlightsQueryConstants.offset: offset]
        return parameters
    }
    
    /**
     Formates date to string using formatter
     - parameters:
     - date: date
     - returns: String representation of date with format
     */
    
    fileprivate func getFormatedDated(date : Date) -> String {
        let formatter = DateFormatter()
        // required format: 29/09/2017
        formatter.dateFormat = "dd/MM/YYYY"
        
        return formatter.string(from: date)
    }
    
    /**
     Convenience method for obtaining todays date
     */
    fileprivate func getFormaterTomorrow() -> String? {
        
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            return nil
        }
        return getFormatedDated(date: nextDay)
    }
    
    /**
     Convenience method for obtaining todays date
     */
    fileprivate func getFormatedToday() -> String? {
        return getFormatedDated(date: Date())
    }
}
