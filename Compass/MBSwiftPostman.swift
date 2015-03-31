//
//  MBSwiftPostman.swift
//  Compass
//
//  Created by Mark on 2/27/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import Foundation

class MBSwiftPostman {
    
    // MARK: UserAE POST Functions
    
    func createNewUserContainer() {
        // set input method
        let httpMethod = "POST"
        
        let userID = PFUser.currentUser().username
        
        // use this url to create new user ID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // default JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":userID,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
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
    
    // MARK: LocationAE POST Functions
    
    func createContentInstanceWith(beaconID: String) {
        
        // set input method
        let httpMethod = "POST"
        
        // use this url to create contentInstance
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/MACAddrOfPhone/LocBeacon/BeaconID?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        /* use this json payload to create content instances */
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"contentInstance",
            "content": [
                "contentInfo":"ID1",
                "content":beaconID,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
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
    
    // MARK: GET Methods
    
    func getRequest() {
    
        // set input method
        let httpMethod = "GET"
    
        // use this url to get this device's beaconID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/MACAddrOfPhone/LocBeacon/BeaconID/?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=2"
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        // init queue
        let queue = NSOperationQueue()
        
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
                println("An error happened while deserializing the JSON data: \(responseError)\n")
            }
        }        
    }
    
    // MARK: DELETE Methods
    
    func deleteContentInstance() {
     
        // set input method
        let httpMethod = "DELETE"
        
        // use this url to delete content instance
        let urlAsString = "http://localhost:8282/InCSE1/LocationAE/Things/2954A1E2-13FB-4A7C-B89D-6478322525E1/LocIBeacon/IBeaconID/?from=http:localhost:10000&requestIdentifier=12345"
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        // init queue
        let queue = NSOperationQueue()
        
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

