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

class MapViewController: UIViewController, MKMapViewDelegate, ESTBeaconManagerDelegate {
    
    // init beacon manager instance
    let beaconManager : ESTBeaconManager = ESTBeaconManager()
    var closestBeaconID = 0
    
    let colors = [
        48808: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        10869: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        32129: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]
    
    /* Annotations */
    let annotationTitles = ["PHO 111"]
    let annotationCoordinates = [CLLocationCoordinate2DMake(42.349228, -71.106104)]
    var indoorAnnotations = []
    
    // init map view
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
        
        // add annotations
        self.addIndoorAnnotationsToMapView()
        
        // start ranging beacons
        self.setupBeaconRegions()

        // subscribe to location updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedLocation:", name: "newLocationNoti", object: nil)
        
        println("Device Name:  " + UIDevice.currentDevice().name)
        println("Device Model:  " + UIDevice.currentDevice().model)
        println("System Version:  " + UIDevice.currentDevice().systemVersion)
        println("Device ID:  " + UIDevice.currentDevice().identifierForVendor.UUIDString)
        println("\n-------------------------------\n")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Utility Functions
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // MARK: Location Handling Functions
    
    func updatedLocation(noti: NSNotification) {
        
        // try to cast to expected type
        if let info = noti.userInfo {
            
            if let userLocation : CLLocation = info["newLocationResult"] as? CLLocation {
                println("Latitude: \(userLocation.coordinate.latitude)")
                println("Longitude: \(userLocation.coordinate.longitude)")
                println("\n-------------------------------\n")
                
                setCenterOfMapToLocation(userLocation.coordinate)
                
            } else {
                println("Could not find new location...")
            }
        } else {
            println("Wrong userInfo type...")
        }
    }
    
    // MARK: Map Functions
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
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
        if annotation is MKUserLocation {
            return nil
        } else if !(annotation is MBAnnotation) {
            return nil
        }
        
        let reuseID = "marker"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            anView.canShowCallout = true
            
            anView.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as UIButton

        } else {
            anView.annotation = annotation
        }
        
        let customAnnotation = annotation as MBAnnotation
        anView.image = UIImage(named: customAnnotation.imageName)
        
        return anView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            println("Disclosure Pressed! \(view.annotation.title)")
            
            if let mba = view.annotation as? MBAnnotation {
                println("mba.imageName = \(mba.imageName)")
                performSegueWithIdentifier("showIndoorMapView", sender: self)
            }
        }
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
}
