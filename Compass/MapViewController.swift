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

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, ESTBeaconManagerDelegate {
    
    @IBOutlet var findSearchBar: UISearchBar!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /* Beacon managaing */
    let beaconManager : ESTBeaconManager = ESTBeaconManager()
    var closestBeaconID = 0
    
    /* Annotations */
    let annotationTitles = ["PHO 111"]
    let annotationCoordinates = [CLLocationCoordinate2DMake(42.349170, -71.106104)]
    var indoorAnnotations = []
    
    /* Searching */
    var searchActive: Bool = false
    var isMappingQueriedUser: Bool = false
    
    var updatingLocationTimer: NSTimer?
    
    var queriedUser = ""
    var queriedUserUUID = ""
    var queriedUserAnnotation: MBUserLocGPSAnnotation?
    var accuracyFlag = ""
    
    var queriedUserGPSCoordinates = CLLocationCoordinate2DMake(0, 0)
    
    /* Map View */
    @IBOutlet var mapView: MKMapView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mapView = MKMapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // set delegates
        mapView.delegate = self
        beaconManager.delegate = self
        findSearchBar.delegate = self
        
        // add annotations
        self.addIndoorAnnotationsToMapView()
        
        // start ranging beacons
        self.setupBeaconRegions()

        // subscribe to location updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedLocation:", name: "newLocationNoti", object: nil)
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
                userLocView.image = UIImage(named: "user_marker.png")
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
            println("Disclosure Pressed! \(view.annotation.title)")
            
            if let indoorAnnotation = view.annotation as? MBAnnotation {
                performSegueWithIdentifier("showIndoorMapView", sender: self)
            }
            
            if let userGPSLocAnnotation = view.annotation as? MBUserLocGPSAnnotation {
                println("start navigation to user....")
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        // center map to user
        self.setCenterOfMapToLocation(mapView.userLocation.location.coordinate)
    }
    
    // MARK: Search Bar Delegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
        self.findSearchBar.resignFirstResponder()
        
        var searchText = self.findSearchBar.text
        var trimmedSearchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // inital activity indicator setup
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0.0, 0.0, 100, 100))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // add to view and start animation
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // begin ignoring user interaction
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if ((searchText == "") || (trimmedSearchText == "")) {
            // stop animation and end ignoring events
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.displayAlert("Error", error: "Please enter a valid username.")
        } else {
            
            // clear queried user marker if any
            if isMappingQueriedUser {
                let annotationsToRemove = self.mapView.annotations.filter({$0 as? MKUserLocation != self.mapView.userLocation})
                self.mapView.removeAnnotations(annotationsToRemove)
                self.isMappingQueriedUser = false
                
                // readd indoor map markers
                self.addIndoorAnnotationsToMapView()
                
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
            self.updatingLocationTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateQueriedUserLocation", userInfo: nil, repeats: true)
        }
    }
    
    func updateQueriedUserLocation() {
        println("Getting \(self.queriedUser)'s location again...")
        self.getQueriedUserUUID(self.queriedUser)
    }
    
    // MARK: Beacon Functions & Delegate
    
    func setupBeaconRegions() {
        var beaconRegion : ESTBeaconRegion = ESTBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D"), identifier: "Estimotes")
        beaconManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func beaconManager(manager: ESTBeaconManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: ESTBeaconRegion!) {
        
//        // filter out unknown beacons
//        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
//        
//        if (knownBeacons.count > 0) {
//            let closestBeacon = knownBeacons[0] as ESTBeacon
//            
//            println("The closest beacon to me is ID: \(closestBeacon.minor.integerValue)!")
//            self.view.backgroundColor = self.colors[closestBeacon.minor.integerValue]
//            
//            // check if the closest beacon ID has changed value
//            if (self.closestBeaconID != closestBeacon.minor.integerValue) {
//                println("Beacon ID Changed! It is now: \(closestBeacon.minor.integerValue)")
//                
//                // update tree with new beacon ID content instance
//                MBSwiftPostman().createContentInstanceWith(String(self.closestBeaconID))
//            }
//            
//            self.closestBeaconID = closestBeacon.minor.integerValue
//        }
    }
    
    // MARK: Query Location Handling
    
    func getQueriedUserUUID(userid: String) {
        
        let httpMethod = "GET"
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/"+userid+"/?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=2"
        
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
                        self.queriedUserUUID = uuid
                        
                        // find flag for uuid
                        self.getQueriedUUIDAccuracyFlag(uuid)
                        
                    } else {
                        println("Did not find user.")
                    }
                }
                println("\n-------------------------------\n")
                
                if self.queriedUser == "" {
                    self.displayAlert("Oh no!", error: "Did not find username \(userid)")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // stop animation and end ignoring events
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    })
                }
            }
        } // end NSURLConnection block
    }
    
    func getQueriedUUIDAccuracyFlag(uuid: String) {
        
        let httpMethod = "GET"
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+uuid+"/AccuracyFlag/?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=3"
        
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
                        self.accuracyFlag = flag
                        
                        // pass flag to accurate location decision method
                        self.getMostAccurateLocation(self.accuracyFlag)
                        
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
            
            // get beacon indoor position
            
        } else if locBeaconFlag == "0" && locCMXFlag == "1" {
            println("Getting CMX location...")

            // get cmx indoor position
            
        } else if locBeaconFlag == "0" && locCMXFlag == "0" && locGPSFlag == "1" {
            println("Getting GPS location...")

            // get GPS location
            self.extractLatestLocGPSContent()
            
        } else {
            
            self.displayAlert("Oh no!", error: "Could not find any location for \(self.queriedUser)")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // stop animation and end ignoring events
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        }
    }
    
    // MARK: Beacon Query Functions
    
    
    
    // MARK: CMX Query Functions
    
    // MARK: GPS Query Functions
    
    func extractLatestLocGPSContent() {
        
        let httpMethod = "GET"
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/"+self.queriedUserUUID+"/LocGPS/latest?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=2"
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
                
                // extract gps location content
                for obj in json["output"]["ResourceOutput"][0]["Attributes"][7] {
                    println(obj.1)
                    
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
                        self.isMappingQueriedUser = true
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // stop animation and end ignoring events
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        })
                        
                    } else {
                        println("Did not find coords.")
                    }
                }
                println("\n-------------------------------\n")
                
                if self.queriedUserGPSCoordinates.longitude == 0  && self.queriedUserGPSCoordinates.latitude == 0 {
                    self.displayAlert("Oh no!", error: "Error finding \(self.queriedUser)'s GPS location.")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // stop animation and end ignoring events
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    })
                }
            }
        } // end NSURLConnection block
    }
}
