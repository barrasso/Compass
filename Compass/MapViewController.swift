//
//  MapViewController.swift
//  Compass
//
//  Created by Mark on 2/22/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet var usersButton: UIBarButtonItem!
    
    @IBOutlet var findSearchBar: UISearchBar!
    
    @IBOutlet var queryOverlayView: UIView!
    
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var followingNameLabel: UILabel!
    @IBOutlet var stopFollowingButton: UIButton!
    
    let hostname = "52.25.30.141"
    
    /* Annotations */
    let annotationTitles = [
        "Room533",
        "IAPLounge"]

    let annotationCoordinates = [
        CLLocationCoordinate2DMake(42.348164, -71.093903), // Room533
        CLLocationCoordinate2DMake(37.232837,-121.980558)] // IAPLounge
    var indoorAnnotations = []
    
    /* Searching */
    var isMappingQueriedUser: Bool = false
    var updatingLocationTimer: NSTimer?

    var accuracyFlag = ""
    var queriedUser = ""
    var queriedUserUUID = ""
    var queriedUserAnnotation: MBUserLocGPSAnnotation?
    
    var queriedUserBeaconCoordinates = ""
    var queriedUserGPSCoordinates = CLLocationCoordinate2DMake(0, 0)
    
    //MARK: /* Map View */
    var didLoadMapView = false
    @IBOutlet var mapView: MKMapView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mapView = MKMapView()
    }
    
    //MARK: IBActions
    
    @IBAction func stopFollowingButtonPressed(sender: AnyObject) {
        println("pressed STOP!!!!!!!!!!!!!!!!!!!!")
    }
    
    //MARK: /* View Functions */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("queriedUser") {
            if name == "" {
                queryOverlayView.hidden = true
            } else {
                followingNameLabel.text = name
            }
        }
        
        // set delegates
        mapView.delegate = self
        findSearchBar.delegate = self
        
        // add annotations
        self.addIndoorAnnotationsToMapView()

        // check for network connection
        if !MBReachability.isConnectedToNetwork() {
            self.displayAlert("Error", error: "You are not connected to a network.")
        }
        
        // check for reveal controller
        if self.revealViewController() != nil {
            usersButton.target = self.revealViewController()
            usersButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedQueryNotification:", name:"QueryIdentifier", object: nil)
    }
        
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("queriedUser") {
            if name == "" {
                queryOverlayView.hidden = true
            } else {
                queryOverlayView.hidden = false
                followingNameLabel.text = name
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // end editing when touching view
        self.view.endEditing(true)
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
    
    // MARK: Map Utility Functions
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    func setCenterOfMapToUserLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.000001, longitudeDelta: 0.000001)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addIndoorAnnotationsToMapView() {
        for (var i = 0; i < self.annotationTitles.count; i++) {
            var newAnnotation = MBAnnotation(coordinate: self.annotationCoordinates[i], title: self.annotationTitles[i])
            mapView.addAnnotation(newAnnotation)
        }
    }
    
    // MARK: Map View Delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        /* Customize User Location Annotation */
        if annotation is MKUserLocation {
            return nil
        } else if !(annotation is MBAnnotation) {
            let reuseID = "userloc"
            var userLocView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            
            if userLocView == nil {
                userLocView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                userLocView.canShowCallout = true
                userLocView.image = UIImage(named: "userBlue0.png")
            } else {
                userLocView.annotation = annotation
            }
            
            return userLocView
        }
        
        /* Customize MBAnnotations */
        let customReuseID = "marker"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(customReuseID)
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: customReuseID)
            anView.canShowCallout = true
            anView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as! UIButton
            anView.rightCalloutAccessoryView.tintColor = UIColor.blackColor()

        } else {
            anView.annotation = annotation
        }
        
        let customAnnotation = annotation as! MBAnnotation
        anView.image = UIImage(named: customAnnotation.imageName)
        
        return anView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            println("Disclosure Pressed! \(view.annotation.title!)")
            
            
            if let indoorAnnotation = view.annotation as? MBAnnotation {
                
                // set nsuserdefaults indoor location title name
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(view.annotation.title!, forKey: "indoorLocationTitle")
                
                performSegueWithIdentifier("showIndoorMapView", sender: self)
            }
            
            if let userGPSLocAnnotation = view.annotation as? MBUserLocGPSAnnotation {
                println("start navigation to user....")
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        if !didLoadMapView {
            // initially center map to user
            self.setCenterOfMapToLocation(mapView.userLocation.location.coordinate)
            didLoadMapView = true
        }
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.findSearchBar.resignFirstResponder()
        
        var searchText = self.findSearchBar.text
        var trimmedSearchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if ((searchText == "") || (trimmedSearchText == "")) {
            self.displayAlert("Error", error: "Please enter a valid username.")
            
        } else if MBReachability.isConnectedToNetwork() {
            
            // clear queried user marker if any
            if isMappingQueriedUser {
                let annotationsToRemove = self.mapView.annotations.filter({$0 as? MKUserLocation != self.mapView.userLocation})
                self.mapView.removeAnnotations(annotationsToRemove)
                self.isMappingQueriedUser = false
                
                // readd indoor map markers
                self.addIndoorAnnotationsToMapView()
                
                // stop updating user location timer
                self.updatingLocationTimer?.invalidate()
                
                // center map back to user location
                self.setCenterOfMapToLocation(mapView.userLocation.location.coordinate)
            }
            
            // clear cached user query info
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("", forKey: "queriedUser")
            self.queriedUser = ""
            self.queriedUserUUID = ""
            self.accuracyFlag = ""
            
            println("Searching for: \(searchText)...")
            self.getQueriedUserUUID(searchText)
            
            // init update queried user location timer
            self.updatingLocationTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "updateQueriedUserLocation", userInfo: nil, repeats: true)
        } else {
            self.displayAlert("Error", error: "Check your network connection.")
        }
    }
    
    func updateQueriedUserLocation() {
        
        if MBReachability.isConnectedToNetwork() {
        
            println("Getting \(self.queriedUser)'s location again...")
            
            // clear queried user marker if any
            let annotationsToRemove = self.mapView.annotations.filter({$0 as? MKUserLocation != self.mapView.userLocation})
            self.mapView.removeAnnotations(annotationsToRemove)
            
            // readd indoor map markers
            self.addIndoorAnnotationsToMapView()
            
            // continue search
            self.getQueriedUserUUID(self.queriedUser)
        }
    }
    
    // MARK: Query Location Handling
    
    func receivedQueryNotification(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey("queriedUser") {
            if name == "" {
                queryOverlayView.hidden = true
            } else {
                queryOverlayView.hidden = false
                followingNameLabel.text = name
                beginSearchForUser(name)
            }
        }
    }
    
    func beginSearchForUser(username: String) {
        
        if MBReachability.isConnectedToNetwork() {
            
            // clear queried user marker if any
            let annotationsToRemove = self.mapView.annotations.filter({$0 as? MKUserLocation != self.mapView.userLocation})
            self.mapView.removeAnnotations(annotationsToRemove)
            self.isMappingQueriedUser = false
            
            // readd indoor map markers
            self.addIndoorAnnotationsToMapView()
            
            // stop updating user location timer
            self.updatingLocationTimer?.invalidate()
            
            // center map back to user location
            self.setCenterOfMapToLocation(mapView.userLocation.location.coordinate)
            
            // clear cached user query info
            self.queriedUser = username
            self.queriedUserUUID = ""
            self.accuracyFlag = ""
            
            println("Searching for: \(username)...")
            self.getQueriedUserUUID(username)
            
            // init update queried user location timer
            self.updatingLocationTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "updateQueriedUserLocation", userInfo: nil, repeats: true)
        } else {
            self.displayAlert("Error", error: "Check your network connection.")
        }
    }
    
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                    // extract UserAE container list
                    for obj in json["output"]["ResourceOutput"][0]["Attributes"][0] {
                        println(obj.1)
                            
                        // check for queried user id
                        var string: String = obj.1.stringValue
                        if string.rangeOfString(userid, options: nil, range: Range(start: string.startIndex, end: string.endIndex), locale: nil) != nil {
                            println("Found user: \(userid)")
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setObject(userid, forKey: "queriedUser")
                            self.queriedUser = userid
                            
                            // extract uuid
                            var getUUID = string.lastPathComponent
                            var uuid = getUUID.stringByReplacingOccurrencesOfString("]", withString: "", options: .LiteralSearch, range: nil)
                            println("Found user UUID: \(uuid)")
                            self.queriedUserUUID = uuid
                            
                            // find flag for uuid
                            self.getQueriedUUIDAccuracyFlag(uuid)
                            
                        } else {
                            println("Did not find user.")
                        }
                    }
                })

                println("\n-------------------------------\n")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.queriedUser == "" {
                        self.displayAlert("Oh no!", error: "Did not find username \(userid)")
                        
                        // stop updating user location timer
                        self.updatingLocationTimer?.invalidate()
                    }
                })
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
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    // extract UserAE container list
                    for obj in json["output"]["ResourceOutput"][0]["Attributes"][3] {
                        println(obj.1)
                        
                        // check for accuracy flag
                        var flag: String = obj.1.stringValue
                        if flag != "labels" {
                            println("Found flag: \(flag)")
                            
                            self.accuracyFlag = flag
                            
                            // pass flag to accurate location decision method
                            self.getMostAccurateLocation(self.accuracyFlag)
                            
                        } else {
                            println("Did not find flag.")
                        }
                    }
                })
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

            // get GPS location
            self.extractLatestLocGPSContent()
            
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
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

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
                            self.queriedUserBeaconCoordinates = "\(x)" + "," + "\(y)"
                            self.isMappingQueriedUser = true
                            
                            
                            
                            // go to indoor map marker
                            self.updatingLocationTimer?.invalidate()
                            
                            // set nsuserdefaults indoor location title name
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setObject(mapid, forKey: "indoorLocationTitle")
                            self.performSegueWithIdentifier("showIndoorMapView", sender: self)
                            
                        } else {
                            println("Did not find coords.")
                        }
                    }
                })
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
    
    // MARK: CMX Query Functions
    
    func extractLatestLocCMXContent() {
        
    }
    
    // MARK: GPS Query Functions
    
    func extractLatestLocGPSContent() {
        
        let httpMethod = "GET"
        let urlAsString = "http://"+hostname+":8282/InCSE1/LocationAE/Things/"+self.queriedUserUUID+"/LocGPS/latest?from=http:"+hostname+":10000&requestIdentifier=12345&resultContent=6"
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
                println("Got latest LocGPS content.")
                println("\n-------------------------------\n")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    // extract gps location content
                    for obj in json["output"]["ResourceOutput"][0]["Attributes"][7] {
                        
                        // check for coords
                        var string: NSString = obj.1.stringValue
                        if string != "content" {
                            println("Found coords: \(string)!")
                            
                            // convert string to CLLocationCoordinates
                            var splitString = string.componentsSeparatedByString(",")
                            var lat = (splitString[0] as! NSString).doubleValue
                            var long = (splitString[1] as! NSString).doubleValue
                            
                            self.queriedUserGPSCoordinates = CLLocationCoordinate2D(latitude: lat as CLLocationDegrees, longitude: long as CLLocationDegrees)
                            
                            // create new marker
                            var newAnnotation = MBUserLocGPSAnnotation(coordinate: self.queriedUserGPSCoordinates, title: self.queriedUser)
                            self.queriedUserAnnotation = newAnnotation
                            self.mapView.addAnnotation(newAnnotation)
                            
                            // lock on to queried user
                            if !self.isMappingQueriedUser {
                                self.setCenterOfMapToUserLocation(self.queriedUserGPSCoordinates)
                            }
                            
                            self.isMappingQueriedUser = true
                            
                        } else {
                            println("Did not find coords.")
                        }
                    }
                })
                println("\n-------------------------------\n")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.queriedUserGPSCoordinates.longitude == 0  && self.queriedUserGPSCoordinates.latitude == 0 {
                        self.displayAlert("Oh no!", error: "Error finding \(self.queriedUser)'s GPS location.")
                        
                        // stop updating user location timer
                        self.updatingLocationTimer?.invalidate()
                    }
                })
            }
        } // end NSURLConnection block
    }
}
