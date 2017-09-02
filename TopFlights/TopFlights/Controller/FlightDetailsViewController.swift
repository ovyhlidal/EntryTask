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
    
    @IBOutlet weak var flightFromTitleLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var flightToTitleLabel: UILabel!
    
    @IBOutlet weak var flightDuration: UILabel!
    
    @IBOutlet weak var departureTimeLabel: UILabel!
    
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var transfersLabel: UILabel!
    
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(data: TravelItineraryMO) -> Void {
        controllerData = data
    }
    
    func refreshUI() -> Void {
        
        if let data = controllerData {
            
            print(data.description)
            
            if let from = data.flightFromCity  {
                if let to = data.fligltToCity  {
                    let title = String.init(format: "%@ ✈ %@", from, to )
                    flightTitle.text = title
                    flightFromTitleLabel.text = from
                    flightToTitleLabel.text = to
                }
            }
            
            let price = data.price
            priceLabel.text = String(price)
            
            
            if let currency = data.currency {
                currencyLabel.text = currency
            }
            
            if let duration = data.flyDuration {
                flightDuration.text = duration
            }
            
            let departureTime = data.departureTimeUTC
            let dateDeptarture = Date(timeIntervalSince1970: departureTime)
            let departure = UTCToLocal(date: dateDeptarture, toFormat: "hh:mm a, dd MMM yyyy")
            departureTimeLabel.text = departure
            
            
            let arrivalTime = data.arrivalTimeUTC
            let dateArrival = Date(timeIntervalSince1970: arrivalTime )
            let arrival = UTCToLocal(date: dateArrival, toFormat: "hh:mm a, dd MMM yyyy")
            arrivalTimeLabel.text = arrival
            
            
            if let cityImageID = data.flightToCityID {
                destinationImage.sd_setImage(with: URL(string: String.init(format: FlightsQueryConstants.imageAPI, cityImageID)) , placeholderImage: UIImage.init(named: "earthAirplaneIcon.png"), options: SDWebImageOptions.continueInBackground) { (image, error, cache, url) in
                    guard let imageErrorDescription = error?.localizedDescription else {return}
                    print("There was an error, image was not loaded. Error:\(imageErrorDescription)")
                    print(cityImageID)
                }
            }
            
            if let transfers = data.route {
                let transfersCount = transfers.count
                transfersLabel.numberOfLines = transfersCount
                let stringTransferFormat = "%@ ➔ %@\n"
                var transfersString : String = ""
                
                //                for transfer in transfers do {
                //
                //                    guard let transferFrom = transfer.flightFromCity else {return}
                //                    guard let transferTo = transfer.flightToCity else {return}
                //
                //                    transfersString.append(String.init(format:stringTransferFormat, transferFrom, transferTo))
                //                }
                //
                //                if transfersString != ""{
                //                    transfersLabel.text = transfersString
                //                }
            }
        }
    }
    
    /**
     Convert time in UTC to time in local zone and apply format "hh:mm a, dd MMM yyyy"
     - parameters:
     - date: Date object that will be converted
     - toFormat: Format of output string
     */
    
    func UTCToLocal(date:Date, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a, dd MMM yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: dateFormatter.string(from: date))
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: dt!)
    }
    
}
