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
        
        mapView.showsUserLocation = true
        
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
        
        var beaconID = "1"
        
        // set input method & params
        let httpMethod = "GET"
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"contentInstance",
            "content": [
                "contentInfo":"ID1",
                "content":beaconID,
                "resourceName": UIDevice.currentDevice().identifierForVendor.UUIDString
            ]
        ]
        
        // swift http api call
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
