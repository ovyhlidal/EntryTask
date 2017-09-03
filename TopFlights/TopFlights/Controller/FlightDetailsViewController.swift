//
//  FlightDetailsViewController.swift
//  TopFlights
//  FlightDetailsViewController representes one page of information showed to user. There are basic information about flights
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
    
    @IBOutlet weak var flightFromTitleLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var flightToTitleLabel: UILabel!
    
    @IBOutlet weak var flightDuration: UILabel!
    
    @IBOutlet weak var departureTimeLabel: UILabel!
    
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var transfersLabel: UILabel!
    @IBOutlet weak var departureCountryLabel: UILabel!
    @IBOutlet weak var arrivalCountryLabel: UILabel!
    
    static let timeFormat = "HH:mm, dd MMM yyyy"
    static let transferFormat = "%@ ➔ %@\n"
    
    var controllerData : TravelItineraryMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(controllerData != nil)
        {
            refreshUI()
        }
    }
    
    func setData(data: TravelItineraryMO) {
        controllerData = data
    }
    
    func refreshUI() -> Void {
        
        if let data = controllerData {
            
            // Fill all information so user can see it.
            if let from = data.flightFromCity, let to = data.flightToCity   {
                
                let title = String.init(format: "%@ ✈ %@", from, to )
                flightTitle.text = title
                flightFromTitleLabel.text = from
                flightToTitleLabel.text = to
            }
            
            let price = data.price
            priceLabel.text = String(price)
            
            if let countryFrom = data.flightFromCountry, let countryTo = data.flightToCountry{
                departureCountryLabel.text = countryFrom
                arrivalCountryLabel.text = countryTo
            }
            
            if let currency = data.currency {
                currencyLabel.text = currency
            }
            
            if let duration = data.flyDuration {
                flightDuration.text = duration
            }
            
            setDepartureTime(departureTime: data.departureTimeUTC)
            
            setArrivalTime(arrivalTime: data.arrivalTimeUTC)
            
            if let cityImageID = data.flightToCityID {
                setImageWith(cityImageID: cityImageID)
            }
            
            if let transfers = data.route?.array as? [RouteMO] {
                setTransferInformation(transfers: transfers)
            }
        }
    }
    
    /**
     Sets departure time that is converted to local time zone
     - parameters:
     - arrivalTime: Double representing UTC arrival time
     */
    fileprivate func setArrivalTime(arrivalTime: Double) {
        let dateArrival = Date(timeIntervalSince1970: arrivalTime )
        let arrival = convertUTCToLocal(date: dateArrival, toFormat: FlightDetailsViewController.timeFormat)
        arrivalTimeLabel.text = arrival
    }
    
    /**
     Sets arrival time that is converted to local time zone
     - parameters:
     - arrivalTime: Double representing UTC departure time
     */
    fileprivate func setDepartureTime(departureTime: Double) {
        let dateDeptarture = Date(timeIntervalSince1970: departureTime)
        let departure = convertUTCToLocal(date: dateDeptarture, toFormat: FlightDetailsViewController.timeFormat)
        departureTimeLabel.text = departure
    }
    
    
    /**
     Sets image of destination city if exists otherwise displays placeholder image
     */
    fileprivate func setImageWith(cityImageID: String) {
        // used SDWebImage to load image
        destinationImage.sd_setImage(with: URL(string: String.init(format: FlightsQueryConstants.imageAPI, cityImageID)) , placeholderImage: UIImage.init(named: "earthAirplaneIcon.png"), options: SDWebImageOptions.continueInBackground) { (image, error, cache, url) in
            guard let imageErrorDescription = error?.localizedDescription else {return}
            print("There was an error, image was not loaded. Error:\(imageErrorDescription)")
        }
    }
    
    /**
     Create information about transfers from city to city, each transfer is on new line. Result is displayed in UI.
     */
    fileprivate func setTransferInformation(transfers: [RouteMO]) {
        let transfersCount = transfers.count
        transfersLabel.numberOfLines = transfersCount
        
        var transfersString : String = ""
        for transfer in transfers.enumerated() {
            guard let transferFrom = transfer.element.flightFromCity else {return}
            guard let transferTo = transfer.element.flightToCity else {return}
            
            transfersString.append(String.init(format:FlightDetailsViewController.transferFormat, transferFrom, transferTo))
            
        }
        if transfersString != ""{
            transfersLabel.text = transfersString
        }
    }
    
    /**
     Convert time in UTC to time in local zone and apply format "hh:mm a, dd MMM yyyy"
     - parameters:
     - date: Date object that will be converted
     - toFormat: Format of output string
     */
    
    fileprivate func convertUTCToLocal(date:Date, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a, dd MMM yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: dateFormatter.string(from: date))
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: dt!)
    }
}
