//
//  MapViewController.swift
//  Compass
//
//  Created by Mark on 2/22/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Device Name:  " + UIDevice.currentDevice().name)
        println("Device Model:  " + UIDevice.currentDevice().model)
        println("System Version:  " + UIDevice.currentDevice().systemVersion)
        println("Device ID:  " + UIDevice.currentDevice().identifierForVendor.UUIDString)
        println("\n-------------------------------\n")

        let httpMethod = "POST"
        var urlAsString = "http://155.41.17.18:8181/restconf/operations/oneM2M-cSEBase:createResource"
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // set POST input params
        var params: [NSString : AnyObject] =
        [
            "input": [
                "Attributes":[
                    [
                    "attributeName":"resourceType",
                    "attributeValue":"AE"
                    ],
                    [
                    "attributeName":"resourceName",
                    "attributeValue":"LocationAE/Devices/" + UIDevice.currentDevice().identifierForVendor.UUIDString
                    ],
                    [
                    "attributeName":"labels",
                    "attributeValue":"containerunderAE"
                    ],
                    [
                    "attributeName":"ontologyRef",
                    "attributeValue":"/CSE1/122111111"
                    ]
                ],
                "originatorID":"12",
                "resourceURI":"InCSE1"
            ]
        ]
        
        // init queue
        let queue = NSOperationQueue()

        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // create new thread for data request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var responseError: NSError?
            // deserialize json object
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:&responseError)
            
            if responseError == nil {
                println("Successfully deserialized...\n")
                
                if json is NSDictionary {
                    let deserializedDictionary = json as NSDictionary
                    println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                }
                else if json is NSArray {
                    let deserializedArray = json as NSArray
                    println("Deserialized JSON Array = \(deserializedArray)")
                } else {
                    println("Something other object was returned...")
                }
            } else if responseError != nil {
                println("An error happened while deserializing the JSON data: \(responseError)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
