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

    // MARK: Location Manager Delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if isExecutingInBackground {
            // in background - do not do any heavy processing
        } else {
            // in foreground - resume normal processing
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation: AnyObject? = locations.last
        
        NSNotificationCenter.defaultCenter().postNotificationName("newLocationNoti", object: self, userInfo: NSDictionary(object: newLocation!, forKey: "newLocationResult"))
    }
}

