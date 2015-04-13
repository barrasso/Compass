//
//  AppDelegate.swift
//  Compass
//
//  Created by Mark on 2/22/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    var locationManager: CLLocationManager! = nil
    var isExecutingInBackground = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        println("Device Name:  " + UIDevice.currentDevice().name)
        println("Device Model:  " + UIDevice.currentDevice().model)
        println("System Version:  " + UIDevice.currentDevice().systemVersion)
        println("Device ID:  " + UIDevice.currentDevice().identifierForVendor.UUIDString)
        println("\n-------------------------------\n")
        
        // initialize parse sdk
        Parse.setApplicationId("RWNddnNuYwk6BfS87tsIlSXNPX1FIHOsDxYriBId",
            clientKey: "jZtdpdn7ydTL3izCvenqQchVGG5Ctv8ApaLzeq8E")
        
        // init location manager
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        if (self.locationManager.respondsToSelector("requestAlwaysAuthorization")) {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        isExecutingInBackground = true
        
        /* Reduce the accuracy to ease the strain on iOS while in background */
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func applicationWillEnterForeground(application: UIApplication) {
        isExecutingInBackground = false
        
        /* increase location detection accuracy in foreground */
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    // MARK: Location Manager Delegate Methods
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if isExecutingInBackground {
            // in background - do not do any heavy processing
        } else {
            // in foreground - resume normal processing
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation: CLLocation = locations.last as! CLLocation
        
        var lat = newLocation.coordinate.latitude
        var long = newLocation.coordinate.longitude
        var coords = String(format: "%f,%f", lat,long)
        
        // put 1 in LocGPS accuracy flag
        MBSwiftPostman().getFlagEnableForLocGPS()
        
        // post content instance with updated position
        MBSwiftPostman().createLocGPSContentInstance(coords)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location manager failed with error: \(error)")
        
        // put 0 in LocGPS accuracy flag
        MBSwiftPostman().getFlagDisableForLocGPS()
    }
}

