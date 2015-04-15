//
//  LocationViewController.swift
//  Compass
//
//  Created by Mark on 3/31/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UISearchBarDelegate, ESTIndoorLocationManagerDelegate {
    
    @IBOutlet var indoorSearchBar: UISearchBar!
    @IBOutlet var indoorLocationView: ESTIndoorLocationView!
    @IBOutlet var showTraceSwitch: UISwitch!
    @IBOutlet var positionLabel: UILabel!
    
    var location: ESTLocation?
    private var manager: ESTIndoorLocationManager!
    
    let colors = [
        48808: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        10869: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        32129: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadLocationFromJSON()
        
        // init indoor manager
        self.manager = ESTIndoorLocationManager()
        self.manager.delegate = self
        
        // start drawing location
        self.indoorLocationView.drawLocation(self.location)
        self.manager.startIndoorLocation(self.location)
        
        // disable rotation
        self.indoorLocationView.rotateOnPositionUpdate = false
        
        // dummy marker
        let flagView = UIImageView(image: UIImage(named: "user_marker.png"))
        self.indoorLocationView.drawObject(flagView, withPosition: ESTPoint(x: 1.0, y: 1.0))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.manager.stopIndoorLocation()
    }
    
    func loadLocationFromJSON() {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("location", ofType: "json")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil) as! String
        
        let indoorLocation = ESTLocationBuilder.parseFromJSON(content)
        
        self.location = indoorLocation
        self.title = indoorLocation.name
    }
    
    // MARK: UISwitch events
    
    @IBAction func showTraceSwitchChanged() {
        self.indoorLocationView.clearTrace()
        self.indoorLocationView.traceColor = UIColor.blueColor()
        self.indoorLocationView.showTrace = self.showTraceSwitch.on
    }
    
    // MARK: ESTIndoorLocationManager delegate
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, inLocation location: ESTLocation!) {
        
        // user's position inside room
        self.positionLabel.text = NSString(format: "x: %.2f   y: %.2f    α: %.2f",
            position.x,
            position.y,
            position.orientation) as String
        
        // keep updating user location
        self.indoorLocationView.updatePosition(position)
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didFailToUpdatePositionWithError error: NSError!) {
        
        self.positionLabel.text = "It seems that you are outside the location."
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //
    }
    
    // MARK: Beacon Query Functions
//    
//    func extractLatestLocBeaconContent() {
//        let httpMethod = "GET"
//        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+self.queriedUserUUID+"/LocGPS/latest?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=2"
//        let url = NSURL(string: urlAsString)
//        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
//        
//        // config request with timeout
//        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
//        urlRequest.HTTPMethod = httpMethod
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
//        
//        let queue = NSOperationQueue()
//        
//        // create connection on new thread
//        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//            if error != nil {
//                println("Error: \(error)")
//                println("Response: \(response)")
//                
//            } else {
//                
//                // deserialize json object
//                let json = JSON(data: data)
//                println("Got latest LocGPS content.")
//                println("\n-------------------------------\n")
//                
//                // extract gps location content
//                for obj in json["output"]["ResourceOutput"][0]["Attributes"][7] {
//                    
//                    // check for coords
//                    var string: NSString = obj.1.stringValue
//                    if string != "content" {
//                        println("Found coords: \(string)!")
//                        
//                        // convert string to map id, x and y
//                        var splitString = string.componentsSeparatedByString(",")
//                        var mapid = splitString[0] as! NSString
//                        var x = (splitString[1] as! NSString).doubleValue
//                        var y = (splitString[2] as! NSString).doubleValue
//                        
//                        // go to indoor map marker
//                        
//                        
//                        self.isMappingQueriedUser = true
//                        
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            // stop animation and end ignoring events
//                            self.activityIndicator.stopAnimating()
//                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                        })
//                        
//                    } else {
//                        println("Did not find coords.")
//                    }
//                }
//                println("\n-------------------------------\n")
//                
//                if self.queriedUserBeaconCoordinates == "" {
//                    self.displayAlert("Oh no!", error: "Error finding \(self.queriedUser)'s indoor location.")
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        // stop animation and end ignoring events
//                        self.activityIndicator.stopAnimating()
//                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                    })
//                }
//            }
//        } // end NSURLConnection block
//    }
}
