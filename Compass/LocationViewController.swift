//
//  LocationViewController.swift
//  Compass
//
//  Created by Mark on 3/31/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UISearchBarDelegate, ESTIndoorLocationManagerDelegate {
    
    let hostname = "52.25.30.141"
    
    @IBOutlet var indoorSearchBar: UISearchBar!
    @IBOutlet var indoorLocationView: ESTIndoorLocationView!
    @IBOutlet var showTraceSwitch: UISwitch!
    @IBOutlet var positionLabel: UILabel!
    
    var location: ESTLocation?
    private var manager: ESTIndoorLocationManager!
    
    var queriedUserView = UIImageView?()
    
    /* Searching */
    var isMappingQueriedUser: Bool = false
    var updatingLocationTimer: NSTimer?
    
    var accuracyFlag = ""
    var queriedUser = ""
    var queriedUserUUID = ""
    var queriedUserAnnotation: MBUserLocGPSAnnotation?
    
    var queriedUserBeaconCoordinates = ""
    var queriedUserGPSCoordinates = CLLocationCoordinate2DMake(0, 0)
    
    let colors = [
        48808: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        10869: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        32129: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indoorSearchBar.delegate = self
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
        
        // check for network connection
        if !MBReachability.isConnectedToNetwork() {
            self.displayAlert("Error", error: "You are not connected to a network.")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.manager.stopIndoorLocation()
    }
    
    func loadLocationFromJSON() {
        let bundle = NSBundle.mainBundle()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("indoorLocationTitle")
        {
        let indoorLocationName = "\(name)"+"-location"
        let path = bundle.pathForResource(indoorLocationName, ofType: "json")
            println("Loaded: \(indoorLocationName)!!!!")
        let content = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil) as! String
        
        let indoorLocation = ESTLocationBuilder.parseFromJSON(content)
        
        self.location = indoorLocation
        self.title = indoorLocation.name
        } else {
            println("Error loading indoor location!")
        }
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
        self.indoorSearchBar.resignFirstResponder()
        
        var searchText = self.indoorSearchBar.text
        var trimmedSearchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if ((searchText == "") || (trimmedSearchText == "")) {
            self.displayAlert("Error", error: "Please enter a valid username.")
        } else if MBReachability.isConnectedToNetwork() {
            
            // clear queried user marker if any
            if isMappingQueriedUser {

                self.isMappingQueriedUser = false
                
                // stop updating user location timer
                self.updatingLocationTimer?.invalidate()
            }
            
            // clear cached user query info
            self.queriedUser = ""
            self.queriedUserUUID = ""
            self.accuracyFlag = ""
            
            println("Searching for: \(searchText)...")
            self.getQueriedUserUUID(searchText)
            
            // init update queried user location timer
            self.updatingLocationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateQueriedUserLocation", userInfo: nil, repeats: true)
        } else {
            self.displayAlert("Error", error: "Check your network connection.")
        }
    }
    
    func updateQueriedUserLocation() {
        
        if MBReachability.isConnectedToNetwork() {
            println("Getting \(self.queriedUser)'s location again...")
            self.getQueriedUserUUID(self.queriedUser)
        }
    }
    
    // MARK: Query Location Handling
    
    func getQueriedUserUUID(userid: String) {
        
        let httpMethod = "GET"
        let urlAsString = "http://"+hostname+":8282/InCSE1/UserAE/"+userid+"/?from=http:"+hostname+":10000&requestIdentifier=12345&resultContent=6"
        
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        let queue = NSOperationQueue()
        
        // create connection on new thread
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("Error: \(error)")
                println("Response: \(response)")
                
            } else {
                
                // deserialize json object
                let json = JSON(data: data)
                println("Got \(userid) container under UserAE.")
                println("\n-------------------------------\n")
                
                // extract UserAE container list
                for obj in json["output"]["ResourceOutput"][0]["Attributes"][0] {
                    println(obj.1)
                    
                    // check for queried user id
                    var string: String = obj.1.stringValue
                    if string.rangeOfString(userid, options: nil, range: Range(start: string.startIndex, end: string.endIndex), locale: nil) != nil {
                        println("Found user: \(userid)")
                        self.queriedUser = userid
                        
                        // extract uuid
                        var getUUID = string.lastPathComponent
                        var uuid = getUUID.stringByReplacingOccurrencesOfString("]", withString: "", options: .LiteralSearch, range: nil)
                        println("Found user UUID: \(uuid)")
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.queriedUserUUID = uuid
                        
                            // find flag for uuid
                            self.getQueriedUUIDAccuracyFlag(uuid)
                        })
                        
                    } else {
                        println("Did not find user.")
                    }
                }
                println("\n-------------------------------\n")
                
                if self.queriedUser == "" {
                    self.displayAlert("Oh no!", error: "Did not find username \(userid)")
                    
                    // stop updating user location timer
                    self.updatingLocationTimer?.invalidate()
                }
            }
        } // end NSURLConnection block
    }
    
    func getQueriedUUIDAccuracyFlag(uuid: String) {
        
        let httpMethod = "GET"
        let urlAsString = "http://"+hostname+":8282/InCSE1/LocationAE/Things/"+uuid+"/AccuracyFlag/?from=http:"+hostname+":10000&requestIdentifier=12345&resultContent=5"
        
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        let queue = NSOperationQueue()
        
        // create connection on new thread
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("Error: \(error)")
                println("Response: \(response)")
                
            } else {
                
                // deserialize json object
                let json = JSON(data: data)
                println("Got AccuracyFlag Container for \(uuid)")
                println("\n-------------------------------\n")
                
                // extract UserAE container list
                for obj in json["output"]["ResourceOutput"][0]["Attributes"][3] {
                    println(obj.1)
                    
                    // check for accuracy flag
                    var flag: String = obj.1.stringValue
                    if flag != "labels" {
                        println("Found flag: \(flag)")
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.accuracyFlag = flag
                        
                            // pass flag to accurate location decision method
                            self.getMostAccurateLocation(self.accuracyFlag)
                        })
                        
                    } else {
                        println("Did not find flag.")
                    }
                }
                println("\n-------------------------------\n")
            }
        } // end NSURLConnection block
    }
    
    func getMostAccurateLocation(flag: String) {
        
        println("Finding best location...")
        
        var locBeaconFlag = flag[flag.startIndex]
        var locCMXFlag = flag[advance(flag.startIndex, 1)]
        var locGPSFlag = flag[advance(flag.startIndex, 2)]
        println("LocBeacon Flag = \(locBeaconFlag)")
        println("LocCMX Flag = \(locCMXFlag)")
        println("LocGPS Flag = \(locGPSFlag)")
        
        // choose best locating method
        if locBeaconFlag == "1" {
            println("Getting beacon location...")
            
            // get beacon indoor position and go to map marker
            self.extractLatestLocBeaconContent()
            
        } else if locBeaconFlag == "0" && locCMXFlag == "1" {
            println("Getting CMX location...")
            
            // get cmx indoor position
            
            
        } else if locBeaconFlag == "0" && locCMXFlag == "0" && locGPSFlag == "1" {
            println("Getting GPS location...")
            
            // go back to outdoor map view
            self.navigationController?.popViewControllerAnimated(true)
            
        } else {
            
            self.displayAlert("Oh no!", error: "Could not find any location for \(self.queriedUser)")
            
            // stop updating user location timer
            self.updatingLocationTimer?.invalidate()
        }
    }
    
    
    // MARK: Beacon Query Functions
    
    func extractLatestLocBeaconContent() {
        let httpMethod = "GET"
        let urlAsString = "http://"+hostname+":8282/InCSE1/LocationAE/Things/"+self.queriedUserUUID+"/LocBeacon/latest?from=http:"+hostname+":10000&requestIdentifier=12345&resultContent=6"
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        let queue = NSOperationQueue()
        
        // create connection on new thread
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("Error: \(error)")
                println("Response: \(response)")
                
            } else {
                
                // deserialize json object
                let json = JSON(data: data)
                println("Got latest LocBeacon content.")
                println("\n-------------------------------\n")
                
                // extract gps location content
                for obj in json["output"]["ResourceOutput"][0]["Attributes"][7] {
                    
                    // check for coords
                    var string: NSString = obj.1.stringValue
                    if string != "content" {
                        println("Found indoor location: \(string)!")
                        
                        // split string into map id, x and y
                        var splitString = string.componentsSeparatedByString(",")
                        var mapid = splitString[0] as! NSString
                        var x = splitString[1] as! NSString
                        var y = splitString[2] as! NSString
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // meanwhile... on the main thread...
                            self.queriedUserBeaconCoordinates = "\(x)" + "," + "\(y)"
                            self.isMappingQueriedUser = true
                            
                            // convert indoor coords to view coords
                            var viewX = self.indoorLocationView.calculatePictureCoordinateForRealX(x.doubleValue)
                            var viewY = self.indoorLocationView.calculatePictureCoordinateForRealY(y.doubleValue)
                            
                            // clear and add new marker for user's indoor position
                            self.queriedUserView = UIImageView(frame: CGRectMake(viewX, viewX, 24.0, 32.0))
                            var userImage = UIImage(named: "compass_icon.png")
                            self.queriedUserView?.image = userImage
                            self.queriedUserView?.tag = 8
                            self.indoorLocationView.viewWithTag(8)?.removeFromSuperview()
                            self.indoorLocationView.addSubview(self.queriedUserView!)
                        })
                        
                    } else {
                        println("Did not find coords.")
                    }
                }
                println("\n-------------------------------\n")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.queriedUserBeaconCoordinates == "" {
                        self.displayAlert("Oh no!", error: "Error finding \(self.queriedUser)'s indoor location.")
                        
                        // stop updating user location timer
                        self.updatingLocationTimer?.invalidate()
                    }
                })
            }
        } // end NSURLConnection block
    }
    
    // MARK: View Utility Functions
    
    func displayAlert(title:String, error:String) {
        // display error alert
        var errortAlert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        errortAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            // close alert
        }))
        
        self.presentViewController(errortAlert, animated: true, completion: nil)
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
