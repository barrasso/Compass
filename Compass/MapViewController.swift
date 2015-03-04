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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mapView = MKMapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true

        // subscribe to location updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedLocation:", name: "newLocationNoti", object: nil)
        
        println("Device Name:  " + UIDevice.currentDevice().name)
        println("Device Model:  " + UIDevice.currentDevice().model)
        println("System Version:  " + UIDevice.currentDevice().systemVersion)
        println("Device ID:  " + UIDevice.currentDevice().identifierForVendor.UUIDString)
        println("\n-------------------------------\n")
        
        // do logic to determine what beacon im next to
        
        // when updating beacon id, send flag to locplugin for uri of updated content
        // walk in front of beacon 1 then post
        // fetch content
        // walk in front of beacon 2 then post
        // fetch content
        
        // fetch things/beaconid/numberIrecieved/content
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Location Handling
    
    func updatedLocation(noti: NSNotification) {
        
        // try to cast to expected type
        if let info = noti.userInfo {
            
            if let userLocation : CLLocation = info["newLocationResult"] as? CLLocation {
                println("Latitude: \(userLocation.coordinate.latitude)")
                println("Longitude: \(userLocation.coordinate.longitude)")
                println("\n-------------------------------\n")
                
                addPinToMapView(userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                
            } else {
                println("Could not find new location...")
            }
        } else {
            println("Wrong userInfo type...")
        }
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addPinToMapView(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        // create location coordinate
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
//        // instantiate annotation
//        let annotation = MBAnnotation(coordinate: location, title: "Current Location", subtitle: "test")
//        mapView.addAnnotation(annotation)
        
        setCenterOfMapToLocation(location)
    }
    
    // MARK: IBActions
    
    @IBAction func getButtonSelected(sender: AnyObject) {
        MBSwiftPostman().getRequest()
    }
    
    @IBAction func postButtonSelected(sender: AnyObject) {
        MBSwiftPostman().createContentInstanceWith("2")
    }
    
    @IBAction func deleteButtonSelected(sender: AnyObject) {
        MBSwiftPostman().deleteContentInstance()
    }
    
}
