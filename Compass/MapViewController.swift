//
//  MapViewController.swift
//  Compass
//
//  Created by Mark on 2/22/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    // MARK: View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let httpMethod = "POST"
        var urlAsString = "http://155.41.17.18:8181/restconf/operations/oneM2M-cSEBase:createResource"
        
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        var err: NSError?
        
        // set POST params
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
                    "attributeValue":"ae11"
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
        
        // init session
        var session = NSURLSession.sharedSession()
        
        // config request
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // start data task
        var task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) -> Void in
            var responseError: NSError?
            
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:&responseError )
            
            if responseError == nil {
                
                println("successfully deserialized...")
                
                if json is NSDictionary {
                    let deserializedDictionary = json as NSDictionary
                    println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                }
                else if json is NSArray {
                    let deserializedArray = json as NSArray
                    println("Deserialized JSON Array = \(deserializedArray)")
                } else {
                    println("wat")
                }
            } else if responseError != nil {
                println("An error happened while deserializing the JSON data: \(responseError)")
            }
        })
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
