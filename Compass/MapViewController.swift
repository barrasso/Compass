//
//  MapViewController.swift
//  Compass
//
//  Created by Mark on 2/22/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        mapView.showsUserLocation = true
        
//        // 1
//        let location = CLLocationCoordinate2D(
//            latitude: 51.50007773,
//            longitude: -0.1246402
//        )
//        // 2
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegion(center: location, span: span)
//        mapView.setRegion(region, animated: true)
//        
//        //3
//        let annotation = MKPointAnnotation()
//        annotation.setCoordinate(location)
//        annotation.title = "Big Ben"
//        annotation.subtitle = "London"
//        mapView.addAnnotation(annotation)
        
        println("Device Name:  " + UIDevice.currentDevice().name)
        println("Device Model:  " + UIDevice.currentDevice().model)
        println("System Version:  " + UIDevice.currentDevice().systemVersion)
        println("Device ID:  " + UIDevice.currentDevice().identifierForVendor.UUIDString)
        println("\n-------------------------------\n")

        // set input method & params
        let httpMethod = "POST"
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":"LocationAE/Things/Testings/" + UIDevice.currentDevice().identifierForVendor.UUIDString
            ]
        ]
        
        // swift api call
        MBSwiftPostman(method: httpMethod, jsonPayloadParams: params)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


///// OLD JSON Payload object
//
//var params: [NSString : AnyObject] =
//[
//    "input": [
//        "Attributes":[
//            [
//                "attributeName":"resourceType",
//                "attributeValue":"AE"
//            ],
//            [
//                "attributeName":"resourceName",
//                "attributeValue":"LocationAE/Things/" + UIDevice.currentDevice().identifierForVendor.UUIDString
//            ],
//            [
//                "attributeName":"labels",
//                "attributeValue":"containerunderAE"
//            ],
//            [
//                "attributeName":"ontologyRef",
//                "attributeValue":"/CSE1/122111111"
//            ],
//        ],
//        "originatorID":"12",
//        "resourceURI":"InCSE1"
//    ]
//]
