//
//  MBSwiftPostman.swift
//  Compass
//
//  Created by Mark on 2/27/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import Foundation

class MBSwiftPostman {
    
    let httpMethod : String!
    let urlAsString : String!
    var jsonPayload : [NSString : AnyObject]
    
    init(method: String!, jsonPayloadParams: [NSString : AnyObject]) {
        self.httpMethod = method
        self.jsonPayload = jsonPayloadParams
        
        switch (method) {
        case "POST":
            
            self.urlAsString = "http://localhost:8282/InCSE1/LocationAE/Things/"+UIDevice.currentDevice().identifierForVendor.UUIDString+"?from=http:localhost:10000&requestIdentifier=12345"
            
            
            println("Using POST method...")
            break;
        case "GET":
            
            self.urlAsString = "http://localhost:8282/InCSE1/LocationAE/Things/BeaconID/Latest?from=coap:localhost:10000&requestIdentifier=12345"
            
            
            println("Using GET method...")
            break;
        case "DELETE":
            self.urlAsString = "http://localhost:8282/InCSE1?from=http:localhost:10000&requestIdentifier=12345"
            println("Using DELETE method...")
            break;
        default:
            println("Invalid HTTP method.")
            break;
        }
        
        // url request properties
        let url = NSURL(string: self.urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // init queue
        let queue = NSOperationQueue()
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = self.httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(self.jsonPayload, options: nil, error: &err)
        
        // create connection on a new thread for request
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
    
    
}